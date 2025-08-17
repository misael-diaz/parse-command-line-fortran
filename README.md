# Packmol command-line argument documentation

## Example

Packmol now support command-line arguments so that users can specify the names of the
input and output files. The following snippet shows a sample command-line string:

```sh
packmol -in input.txt -out output.txt
```

If you ommit command-line arguments packmol will behave in the usual way and will expect
you to redirect the input file for backwards compatibility:

```sh
packmol < input.txt
```

## Compilation

To compile the source code in this repository you may use the following command:

```sh
gfortran -g -Wall -O0 main.f90 -o packmol
```

to compile the source with the GNU Fortran compiler.

## Execution

Since this is not the official packmol source code, just a concept you will have to
modify the above commands to provide the relative path to the packmol executable.

Executing packmol with command-line arguments:

```sh
./packmol -in input.txt -out output.txt
```

Executing packmol with input redirection:

```sh
./packmol < input.txt
