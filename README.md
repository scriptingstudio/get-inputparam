# Get-inputparam 

***Get-inputparam*** is a simple powershell-like input **named** parameter parser for shell scripts implemented as a function.

## Why?
Bash does not have any "blackbox" solution for input parsing. Neither getopt nor getopts have that simplicity, clarity and power in input processing as Windows Powershell. Having been vastly experienced in Powershell I did need the solution for my shell scripts. I got it of "a few" lines.

## Features
* Powershell-like syntax schema and processing.
* "Blackbox" input processor.
* Input parameter name maps on to output variable.
* Input parameter optional duplication: conflict detection or last wins.
* Input parameter expansion. You can type a few first letters of a parameter (shortcut), the processor will expand it to the full name.
* Parameter name intersection detection. If any of two entered parameter shortcuts intersect, the processor will find the conflict. Exact name coincidence will win.
* Parameter synonyms. The first syn of definition is an output varname.
* Parameter default value. Default value can be an array.
* Optional output variable prefix. This prefix will be added to all variable names.

## Notes
* Tested in Mac OS X.

## Usage
#### Command line schema
Powershell terminology is used.

```sh
$ <script> -<parameter> [<argument> <argument>...]...
```
#### Function usage
```sh
get-inputparam [-d] <parameter_definition_array_name> -|<output_variable_prefix> "{@}"
```

#### Input
| Argument | Description | Required |
|:---------|:------------|:---------|
| $1 | Switch `-d` to check for duplicates of input parameters. Put it before parameter definition array name. | Optional |
| $1 | Parameter definition array name (just name, not value!) | Mandatory |
| $2 | Output variable prefix. To omit prefix use argument `'-'`. | Mandatory |
| $3 | Input arguments, i.e. `"${@}"`. | Mandatory |

#### Output
Variables named by parameters. If an output variable is assigned value `true` that means the parameter is called in command line and it did not have a predefined value.

#### Error messages
| Reason | Message |
|:-------|:--------|
| Parameter duplicates found | *WARNING: Duplicate input parameter(s) '\<name list\>'.* |
| Undefined parameter found | *WARNING: Unknown parameter '\<name\>'.* |
| Definition array not found | *ERROR: Parameter definitions not found.* |
| Intersection conflict found | *ERROR: Ambitious parameter '\<input\>' =\> '\<parameter name\>'.* |

## Parameter definition block
#### Schema
```sh
<block_name>=(
	<param_name>[|<synonym>...][=<default_value>]
	...
	<param_name>[|<synonym>...][=<default_value>]
) 
```

#### Explanation

* Definition block is regular shell array.
* Each line is separate array text element which can contain any expression like variables and commands.
* Character '|' (pipe) is a delimiter of param names (synonyms). **Note:** if there are synonyms this parameter line must be quoted.
* Character '=' is a delimiter of param name and its default value if any.
* If default value is an array it should be enclosed in single quotes.

#### Example

```sh
params=(
    name=$(echo $USER)
    'computer|host'=$(hostname)
    company
    class
    lang='(en de pl)'
    log=myscript.log
    'help|?'
    run
)
```
In the example above,

* parameter `name` has a default value as an expression;

* parameter `computer` has synonyms delimited by '|' and a default value as an expression;

* parameter `lang` is assigned a default value as an array;

* parameter `log` is assigned a string type default value.

## Demo play to learn
Download *get-inputparam-function.sh* script and play with parameters.

Enter `-na` to see how expansion works.

Enter `-com` to see how intersection works.

Enter `-comp` to see how exact name coincidence works.

Change prefix, variable `px`, with your choice to see output varnames.

Remove/leave switch `-d` to play with duplicates of input.
