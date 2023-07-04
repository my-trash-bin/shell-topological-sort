# Shell topological sort

POSIX-compliant topological sort using shell script

## Usage

Prepare your input file, and redirect it into its stdin.

```shell
sh main.sh < input.properties
```

## Input file format

Just as like `.properties` file.

Each line is in form `KEY=VALUE` where VALUE is space-separated dependencies of KEY

Example below

```text
minirt.exe=-lminirt -lminirt_args
-lminirt=-lcommon -lm
-lcommon=-lc
-lminirt_args=-lcommon
```

output:

```text
-lc
-lcommon
-lm
-lminirt
-lminirt_args
minirt.exe
```

## Restrictions

- No detection for dependency cycle.
- Line break and equal sign and spaces are not supported due to file format.
