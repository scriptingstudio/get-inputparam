# Get-inputparam for shell

***Get-inputparam*** is a simple powershell-like input **named** parameter parser for shell scripts implemented as a function.

## Why?
Bash does not have any "blackbox" solution for input parsing. Neither getopt nor getopts have that simplicity and power in input processing like Powershell. Having been vastly experienced in Powershell I did need the solution for my shell scripts. I got it of "hundred" lines.

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
* Tested in Mac OS X.

## Usage
#### Command line schema: 
~~~sh
$ <script> -<parameter> [<argument> <argument>...]...
~~~
#### Function usage:
~~~sh
get-inputparam [-d] <parameter_definition_array_name> -|<output_variable_prefix> "{@}"
~~~
#### Input:
$1 — switch <code>-d</code> to check for duplicates of input parameters. Optional.

$1 — parameter definition array name (just name, not value!). Mandatory.

$2 — output variable prefix. To omit prefix use '-'. Mandatory.

$3 — input parameters. Mandatory. 
#### Output: 
Variables named by parameters.
#### Error messages:
<table>
<th>Reason</th> <th>Message</th>
</tr></thead>
<tr><td>Parameter duplicates found</td> <td><i>WARNING: Duplicate input parameter(s) '&lt;name list&gt;'</i></td></tr>
<tr><td>Undefined parameter found</td> <td><i>WARNING: Unknown parameter '&lt;name&gt;'</i></td></tr>
<tr><td>Definition array not found</td> <td><i>ERROR: Parameter definitions not found</i></td></tr>
<tr><td>Intersection conflict found</td> <td><i>ERROR: Ambitious parameter '&lt;input&gt;' =&gt; '&lt;parameter name&gt;'</i></td></tr>
</table>

## Demo play to learn
Download get-inputparam-function.sh script and play with parameters.

Enter <code>-na</code> to see how expansion works.

Enter <code>-com</code> to see how intersection works.

Enter <code>-comp</code> to see how exact name coincidence works.

Change prefix, variable <code>px</code>, with your choice to see output varnames.

Remove/leave switch <code>-d</code> to play with duplicates of input.


