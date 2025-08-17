! Assumption:
! Packmol is being executed in an Unix-like operative system and so the program name is
! present in the command-line string. If that's not the case we abort execution because
! we are not handling that special case.

module parser
    implicit none
    integer, parameter :: INPUT_FLAG = 0
    integer, parameter :: OUTPUT_FLAG = 1
    integer, parameter :: cmdsz = 256
    integer, parameter :: fnamesz = 512

    private
    public :: INPUT_FLAG
    public :: OUTPUT_FLAG
    public :: cmdsz
    public :: fnamesz
    public :: parse_command
    public :: get_filename
contains
    function parse_command(cmd) result(res)
        integer :: res
        integer :: idx
        character(*), intent(in) :: cmd

        idx = index(cmd, "-in")
        if (idx /= 0) then
            res = INPUT_FLAG
        else
            res = OUTPUT_FLAG
        end if

        return
    end function parse_command

    subroutine get_filename(cmdno, filename)
        integer, intent(in) :: cmdno
        character(*), intent(out) :: filename

        call get_command_argument(cmdno + 1, filename)

        return
    end subroutine get_filename

end module parser

program main
    use parser
    implicit none
    integer :: idx
    integer :: stat
    integer :: argc
    integer :: cmdno
    integer :: length
    logical :: specified_input_file
    logical :: specified_output_file
    character(len=cmdsz) :: cmd
    character(len=fnamesz) :: input_file
    character(len=fnamesz) :: output_file
    character(len=*), parameter :: errmsg = "ERROR: packmol command-line error show help"

    specified_input_file = .false.
    specified_output_file = .false.

    argc = command_argument_count()
    if (argc == 0) then ! packmol default mode with input redirection

        cmdno = 0
        call get_command_argument(cmdno, value=cmd, length=length, status=stat)
        if (stat == -1) then
            error stop "ERROR: truncation error"
        else if (stat > 0) then
            error stop "ERROR: command-line retrieval error"
        end if

        ! CAVEAT this could be a false positive if the sysadmin renames packmol
        idx = index(cmd, "packmol")
        if (idx == 0) then
            error stop "ERROR: packmol detected non-standard command-line handling"
        end if

    else if (argc == 2) then ! user may have specified the input or the output file

        cmdno = 1
        call get_command_argument(cmdno, value=cmd, length=length, status=stat)
        if (stat == -1) then
            error stop "ERROR: truncation error"
        else if (stat > 0) then
            error stop "ERROR: command-line retrieval error"
        end if

        if (parse_command(cmd) == INPUT_FLAG) then
            call get_filename(cmdno, input_file)
            specified_input_file = .true.
            write (*, *) "input: ", trim(input_file)
        else if (parse_command(cmd) == OUTPUT_FLAG) then
            call get_filename(cmdno, output_file)
            specified_output_file = .true.
            write (*, *) "output: ", trim(output_file)
        else
            error stop "ERROR: packmol received invalid command-line arguments"
        end if

    else if (argc == 4) then ! user has specified both the input and output files

        cmdno = 1
        call get_command_argument(cmdno, value=cmd, length=length, status=stat)
        if (stat == -1) then
            error stop "ERROR: truncation error"
        else if (stat > 0) then
            error stop "ERROR: command-line retrieval error"
        end if

        if (parse_command(cmd) == INPUT_FLAG) then
            call get_filename(cmdno, input_file)
            specified_input_file = .true.
        else if (parse_command(cmd) == OUTPUT_FLAG) then
            call get_filename(cmdno, output_file)
            specified_output_file = .true.
        else
            error stop "ERROR: packmol received invalid command-line arguments"
        end if

        cmdno = 3
        call get_command_argument(cmdno, value=cmd, length=length, status=stat)
        if (specified_input_file) then
            if (parse_command(cmd) == OUTPUT_FLAG) then
                call get_filename(cmdno, output_file)
                specified_output_file = .true.
            end if
        else
            if (parse_command(cmd) == INPUT_FLAG) then
                call get_filename(cmdno, input_file)
                specified_input_file = .true.
            else
                error stop "ERROR: packmol received invalid command-line arguments"
            end if
        end if

        ! assertion: both must be true if not we have a logic error in the code
        if (.not. specified_input_file .or. .not. specified_output_file) then
            error stop "ERROR: packmol received invalid command-line arguments"
        end if

        write (*, *) "input: ", trim(input_file)
        write (*, *) "output: ", trim(output_file)

    else ! user provided invalid command-line arguments
        error stop errmsg
    end if

end program main
