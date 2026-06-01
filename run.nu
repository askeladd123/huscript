
const SCHEMA_IN = './in-schema.json'
const CONFIG = './in/config.toml'

def rent_acc [years, initial_monthly_kr, increase_yearly_percentage]: any -> float {
  let months = ($years * 12 | math round)
  if $months == 0 { return 0.0 }
  0..($months - 1) | each {|month|
    let year = ($month / 12 | math floor)
    $initial_monthly_kr * (1 + $increase_yearly_percentage / 100) ** $year
  } | math sum
}

# calculates gains from investment in a stock fund. Remember, profits are taxed, but only on payback.
def stock_fund_gains_brutto [years, capital_kr, increase_yearly_percentage]: any -> float {
  ($capital_kr * (1 + $increase_yearly_percentage / 100) ** $years) - $capital_kr
}

def buy [] {
  print --stderr 'not implemented'
  exit -1
}

def check_plugins [] {
  let plugins = plugin list
  let plotters = $plugins | where name == plotters | first
  if ($plotters | is-empty) {
    print --stderr 'plugin `plotters` not installed'
    exit -1
  }
  const desired_version = '0.2.5+0.111.0'
  if $plotters.version != $desired_version {
    print --stderr 'plugin `plotters` is of different version'
    print --stderr $'- expected: ($desired_version)'
    print --stderr $'- got: ($plotters.version)'
  }
}

def get_cli_input [use_config, stdin]: any -> record {
  let use_stdin = $stdin | is-not-empty

  print --stderr 'validating input with json schema'
  if (not $use_config) and (not $use_stdin) {
    print --stderr 'error: need input from `stdin`, `config` or both.'
    exit -1
  }
  if $use_config and not $use_stdin {
    let out = check-jsonschema --schemafile $SCHEMA_IN $CONFIG | complete
    print --stderr $out.stderr $out.stdout
    if $out.exit_code != 0 { exit -1 }
    return (open $CONFIG)
  }
  if $use_stdin and not $use_config {
    let out = $stdin | check-jsonschema --schemafile $SCHEMA_IN --force-filetype toml - | complete
    print --stderr $out.stderr $out.stdout
    if $out.exit_code != 0 { exit -1 }
    return ($stdin | from toml)
  }
  if $use_stdin and $use_config {
    let out = check-jsonschema --schemafile $SCHEMA_IN $CONFIG | complete
    print --stderr $out.stderr $out.stdout
    if $out.exit_code != 0 { exit -1 }

    let overlay = try { $stdin | from toml } catch {|e|
      print --stderr '`stdin` is not valid toml'
      print --stderr $e.rendered
      exit -1
    }

    let merged = open $CONFIG | merge deep $overlay

    let out = $merged | to json | check-jsonschema --schemafile $SCHEMA_IN - | complete
    print --stderr $out.stderr $out.stdout
    if $out.exit_code != 0 { exit -1 }

    return $merged
  }
}

def 'main schema-in' [] {
  cat $SCHEMA_IN
}

def 'main schema-out' [] {
  print --stderr 'not implemented'
  exit -1
}

def 'main config-path' [] {
  print --stderr ($CONFIG | path expand)
}

def 'main plot' [] {
  print --stderr 'not implemented'
  exit -1
}

# do calculations
# input: one of:
# - stdin: piped toml text, find structure by runnig `schema-in` subcommand
# - config: toml file, with same structure, location found with `config-path` subcommand
# - layered: use both above, where options from `stdin` have precedence, and will override `config` options
# output: csv table containing various insight. Look specifically for column `rent_w_gains`
def 'main crunch' [
  --use-config(-c) # reads data from config file first, then merges any `stdin` on top
] {
  let input = get_cli_input $use_config $in

  let output = 0..0.5..($input.general.years) | each {{year: $in}} |
    insert fund_gains_brutto {
      stock_fund_gains_brutto $in.year $input.general.capital_kr  $input.general.stock_fund.appreciation.yearly_percentage
    } |
    insert fund_gains_netto { $in.fund_gains_brutto * (1 - $input.general.stock_fund.tax_percentage / 100)
    } |
    insert rent_raw { 0 - (rent_acc $in.year $input.rent.rate.monthly_kr $input.rent.rate.yearly_increase_percentage) } |
    insert rent_w_gains { $in.rent_raw + $in.fund_gains_netto }
  print ($output | to csv)
  print --stderr $'After ($input.general.years) years:'
  print --stderr $'- renting costs: ($output | get rent_w_gains | last | math round) kr'
  print --stderr $'- buying costs: <TODO>'
}

# Script to estimate cost of renting or buying in Norway. See subcommand `crunch --help` for more info.
def main [] {
  print --stderr 'use subcommands'
  exit -1
}

