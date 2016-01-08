
This is a readme file on expect-lite (formerly cli_validate_setup.tcl)
by Craig Miller
Revised 4 October 2006

-- Introduction --

What is expect-lite? expect-lite is a wrapper for expect,
created to make expect programming even easier. The wrapper permits the creation of
expect script command files by using single special character at the beginning of
each line to indicate the expect-lite action.

Basic expect-lite scripts can be created by simply cutting and pasting text from a
terminal window into a script, and adding '>' '<' characters.

Expect-lite is targeted at the testing environment, and will produce a Pass/Fail result
at the end of the script, however, its use is not limited to this environment.

-- Automatic Login --

Based on the command line arguments passed, expect-lite will do the following:
o	Automatically log into the remote host (if ssh keys have been previously setup)
o	Change directory to the passed directory (if included)

In the following example of expect-lite: 
	./expect-lite tempest-018 basic_ping_test.txt /etc

expect-lite will log into tempest-018, change directory to /etc/ and begins feeding
commands from basic_ping_test.txt to the tempest.


-- Special Characters --

Expect-lite will interpret the following special characters at the beginning of each
line in the script as:
	> send to the remote host
	>> send to remote host, without waiting for prompt (see implementation details)
	< _MUST_ be received from the remote host, or the script will FAIL!
	# are comment lines, and have no effect
	; are also comment lines, but are printed to stdout (for logging)
	@ change the expect timeout value
	$ indicate a variable to be defined at invocation
	+ used to add a variable dynamically – more later
	~file_name -- will include a expect-lite automation file, useful for creation of
		common var files, or 'subprograms'

In addition the above 8 special characters, blank lines or lines starting with any
non-special character are allowed to make the script file more readable. 

Sometimes control characters must be sent to the host, currently all control
characters are supported (from ^@ to ^\):
	^C or break, when it is desired to stop a running program use: >^C
	^] or escape from telnet, use: >^]
		This will bring the script to the telnet prompt, then use: >quit
	^<any char> will send a control character to the tempest, such as ^D to logout

-- Use of Regex in expect-lite --

Support of regular expressions in expect-lite are limited by:
   1) Support of regex in standard expect (e.g. \t \n are supported, \d is not)
   2) Regex is utilized in expect-lite only on lines that begin with '<' and '+' 

As an example, perhaps a range of numbers is valid for an IP address. The following
would permit the last octet of the IP address to be 2 digits, but not 3
> /sbin/ifconfig eth0
<inet addr:10\.29\.200\.[0-9][0-9][ ]

The periods are preceded by a backslash to indicate to regex that a period must be
returned rather than the regex dot '.' which indicates any character.

Because regex is always enabled on expected results, some 'escaping' of characters
must be done when using '<'. The following characters must be escaped with a
backslash to convey their literal meaning: 
(abc)	->	\(abc\)		parenthesis
[abc]	->	\[abc\]		square brackets
\	->	\\		backslash
.	->	\.		period
$	->	\$		dollar sign


-- Using Variables --

Lines starting with a '$' indicate variables which assigned set at script invocation,
and therefore are static. Sometimes it is desirable to bind a variable during the
execution of the script. Dynamic variables fill this need by utilizing Expect's built-in
regex capture mechanism. The format of the line is as follows: +$somevar=text that is
not put into the var (text which is put into the var)

Dynamic Variables are always bound to Expect output, meaning text which is returned
from the remote host. Therefore something must be sent to the remote host, before
text can be returned. A typical usage would be:
> command
+$myvar=command output (capture value) more command output

If the value of the var is successfully captured then expect-lite will print:
Assigned Var:somevar=sometext which is put into the var

If, however the dynamic var is not successfully captured, expect-lite will print:
Assigned Var:somevar=NONE

This is to indicate that the regex pattern used did not match the return data. It is
best to start using this feature with short scripts targeted at capturing the desired
information. Examples can be found in the example section of this readme.

-- Constants

Expect-lite Constants are variables which are passed into expect-lite at runtime.
Constants will override any script variable already defined inside the script, and
can be used to change the behaviour of the script.

For example, one might invoke the following test as:
	./expect-lite tempest-018 basic_ping_test.txt /etc local_eth=eth2

Inside the script basic_ping_test.txt any reference to $local_eth would be set to
eth2, thus allowing the script actions to be changed based on the constant passed at
invocation. Constants will override any script variable already defined inside the
script.


-- Shell Variables

Expect-lite allows the use of shell variables, which can be more powerful than the
built-in variable mechanism. However Shell variables will only be resolved by the
shell. For example, assigning current working directory to a shell var:
> PWD=`pwd`
> echo $PWD

However, the following would fail, since $PWD is a shell variable, not an expect-lite
variable:
> PWD=`pwd`
>pwd
< $PWD

-- Expect-lite & Bash --

Although not limited to working with bash, bash is invoked upon logging into the remote
host, and therefore will be discussed more here.

The bash shell is well documented, and supported, and therefore can be leveraged to
assist in expect-lite's limitations such as looping and branching (see limitations
below). A simple bash loop inside expect-lite can be created for example:
$set=1 2 3 4 5
>for i in $set 
>{
>echo $i
>}

Or a while loop:
$max=5
>i=0
>while [ $i -lt $max ]
>do
>echo $i
>let i+=1
>done

Conditionals via bash are also be supported, as in this example:
$max=4
>if [ $max -ne 5 ]; then
>echo "max is not equal to 5"
>else
>echo "we have a winner"
>fi

More complex bash assists can be constructed, for example, one may want to set a looping
variable based on the processor type of machine at the time (some hosts may be faster
than others). The answer is echo'ed, and then captured using a dynamic variable. Note
that that 'proc' is prepended to the answer, as it enables the capture to be much more
specific.
>PROC=`uname -i`
>if [ "$PROC" == "i386" ]; then
>echo proc20
>else
>echo proc100
>fi
+loop_counter=\nproc([0-9]+)

Note that 'proc' is outside the parenthesis and therefore will not be captured into the
variable loop_counter.


-- Include Files --

Include files are a quick way to develop script snippets which can be included into
larger scripts or to include a common variable file. When an include file is
executed, it is as if the file were just pasted into the script file, and therefore
has access to variable space of the main script, and can modify that variable space
as well. In this example, a common variable file is “sourced”:
# Source Var file to be used
~asic_vars.inc

Common functions such as telnetting to the cosim are a good use of include files:
; === Connect to Sim 
~cosim_connect.inc

Include filenames can also be assigned in a variable, such that the files can be
declared at the top of the script but used later within the script. For example:
# Source Var file to be used
$asic_include=asic_vars.inc
...
~$asic_include


-- Examples of Expect-lite --

Here are some example to better illustrate what can be accomplished with expect-lite.

-- Starting a NCA2000
# set timeout value to 120 seconds
@120
# ensure the script is logged in as root
>id
<root
>./swy_ctrl.sh --stop
>sleep 2
>./swy_ctrl.sh --reset
<done
>sleep 2
>./swy_ctrl.sh --start   
<sysInitApp

-- Setting the IP address of the Tempest and the NCA2000, then ping from the tempest
to the NCA2000, and validate that the ping was successful
$local_eth=eth0
$ip_addr=192.168.10.2
# change timeout value to 10 sec
@10
>ifconfig $local_eth $ip_addr
>arch/app/swyIfConfig  ip2 192.168.10.99 netmask 255.255.255.0 phyPort 2 up
#check to ensure that we set the right IP address on the NCA2000
>arch/app/swyIfConfig 
<192.168.10.99
>ping 192.168.10.99 -c 3
<3 received

-- Starting a telnet to another host
@2
>telnet tempest-018
<login
>root
<assword
>123456
# issue a command once logged in
>pwd
>^]
>quit

-- Starting a ssh session to another host
>ssh root@tempest-021
<assword:
>123456
>ls
>exit

-- Compiling a Regex File using Vars
$local_regex_test_file=/u/craig/Testing/PM/p1000_x08.txt
$pmm=pm/user/bin/$MYMACH/debug/pmm
; === Add Patterns
> $pmm
>add regex file source $local_regex_test_file
>commit

-- Use of Screen Command to keep swycli alive after test completes
; ==== Use Screen command for to keep swycli running on $hosta ====
# start screen command (with C-b rather than default C-a)
>screen -e^Bb
; === Add Patterns
>  $pmm  --logfile /local/craig/Log/pmm_$HOSTNAME$DATE.log 
>read stats hw
# check that we are inside the screen with pmm running
<Statistics
# Check that HW is alive
>ping
<Successfully pinged the PM H/W
<Successfully pinged the PM H/W
<Successfully pinged the PM H/W
; ==== Keep swycli active, and stop this test
>^B
>^D
<detached

-- Assigning a dynamic variable using regex capture
>uname -a
+$host=Linux ([a-z\-0-9]+)
>

-- Manage multiple Screen commands with a dynamic variable and regex capture
# show the last screen in the list 
>screen -list | grep pts | sort | tail -1
# regex capture to dynamically assign the result to var $myscreen
+$myscreen=([0-9]+\.pts.[0-9]+.[a-z\- 0-9]+)
# connect to $myscreen
> screen -r $myscreen
# inside existing screen, kick it to get a prompt
>^M
> sleep 3
>
>^B
>^D
<detached

-- Using Regex in expect-lite to allow multiple responses
>id
# allow either camelot or pegasus
<(camelot|pegasus)



-- Test Failure?!? --

When will expect-lite fail a test? It will only fail a test when an expected result
(after issuing a command) does not appear in the specified timeout period. For
example in the following command file:
$ip_addr=192.168.10.99
>/sbin/ifconfig eth0 $ip_addr
>/sbin/ifconfig eth0 
< $ip_addr

The first line will be sent (blindly), since there is no expected return. On line 3,
the ifconfig command is sent again, and the script is looking for a desired result
of  192.168.10.99 (using the var $ip_addr). If for some reason the ip address this
value, and different ip address was returned, the script would fail.

-- How can it help? --

Expect-lite can be used to quickly create automated tests. It can collapse
complicated tests into a single command line. It is also being used in the nightly
regression testing, performing simple functional tests providing confidence that core
functionality has not been broken by the previous day's submissions.

-- Limitations --

Expect-lite is limited to what a person can do in one (1) terminal window (or xterm).
It cannot start a program in one window and run a different program in a separate
window. Therefore it does not currently support multiple sessions. Using the Linux
'screen' command can assist in working around this limitation. 

Standard programming constructs such as looping and branching are not supported. Real
Expect can do these things and more. That said, looping and branching can be used via
shell mechanisms bringing some of this functionality to expect-lite (see Expect-lite and
Bash). 

Expect-lite has been purposely limited to keep scripts simple, and easy to use and
maintain. Although more complex scripts can be created, basic expect-lite scripts can be
created by simply cutting and pasting text from a terminal window into a script, and
adding '>' '<' characters.


-- Implementation Details --

-- Variables

Variables names must be restricted to the following set of characters [A-Za-z0-9_].
Variable values may include spaces, and quoting is not required nor permitted. For
example:
$bell=For whom the bell tolls
>echo $bell
For whom the bell tolls

-- Implied “wait for prompt”

Using the '>' character implies waiting for the prompt before sending the command. It
is often useful to follow a '<' with a '>' for force the script to wait for the
prompt:
> $some_long_command
<critical value
# wait for prompt
>

It may be useful to create files on the fly which will be used in the test. This can be
done with the linux command 'cat'. Creating a regex file for example:

; ==== Create Test File
> cat > $local_char_test_file
##### Paste in Regex lines below ####
>>T00001/a(?$XL.*)/tag=0x08000001
>>T00002/b(?$XR.*)/tag=0x08000002
>>T00003/c(?$XO[0-7]*)/tag=0x08000003
>>T00004/d(?$XH[0-9A-F]*)/tag=0x08000004
>>T00005/e(?$XD[0-9]*)/tag=0x08000005
>^D
>

In the above example the script initiates a cat to a file (referenced by
$local_char_test_file ). Normally the '>' would be used to send lines to the remote
host, however, there is an inherent "wait for prompt", and a different special char
must be used. The lines beginning with '>>' will not wait for a prompt, and therefore
will be sent very quickly. After sending the lines to the file, a ^D is sent to stop the
cat command. The last '>' is there to wait for the prompt to return after the cat
command.

-- Timeouts

Setting the expect-lite timeout to 0, isn't actually zero, as this will cause the
keyboard input buffer on the remote machine to overflow (and lose characters).
Expect-lite adds a 50ms delay between lines when the @0 is used to prevent the
overflow.


-- Where is it? -- 
expect-lite can be found in cvs under scripts/tcl/expect-lite 



-- Change Log 
# expect-lite (formerly CLI Validate Setup) Script
# Script logs into Tempest, sends command file, while validating commands
#	fails if validation fails with return code 1 (0=passed)
#
# by Craig Miller 19 Jan 2005
#
# Command Arguments:
#	<TempestName|IP>
#	<command_file>
#
# Updated 1 March 2005
#	Added result codes to align with Vince's Regression wrapper (stub.tst)
#	Added ssh access (not all tempests permit root access via telnet
#
# Updated 3 March 2005 (Girl's Day in Japan)
#	Added swy_ctrl path to be passed via cli arg
#	General clean up, and removal of unused vars and procs
#
# Updated 8 March 2005
#	Added zLogin Proc to handle retry on logins
#
# Updated 9 March 2005
#	Updated zLogin to make it a bit smarter in logging in
#
# Updated 16 March 2005
#	Added ^] to quit a telnet session
#
# Updated 31 March 2005
#	Improved where a `;' comment prints (closer to the next send line)
#
# Updated 12 May 2005
# 	Added Expect Line when test Fails - making it easier to understand failure
#	Moved printing of expect timeout notification 
#
# Updated 17 May 2005
#	Added General control char send facility. Send control chars with >^B
#	Added Var substitution facility. Vars are defined $var=value
#		Vars can't have spaces, but can have '_' or '-'
#
# Updated 2 June 2005
#	Added 'catch' protection to gracefully handle spawn/connection errors
#
# Updated 16 June 2005
#	Updated timeout value (@) to accept leading space i.e. '@ 5'
#		This permits use of Vars in timeout i.e. '@ $mytimeout'
#
# Updated 17 June 2005
#	Added concept of "include file"
#		Include files will be read from same directory as cmd_file
#		Include files share the same Var space as the cmd_file
#
# Updated 13 Sept 2005
#	Added protection (via catch) on '>' send strings to ensure connection to tempest is still good
#		Script terminates with a friendly message if connection is gone
#
# Updated 18 Oct 2005
#	Added Construct of Constants which are passed on the command line (as args > 3)
#		Usage is now: usage: expect-lite <tempest_IP> <command_file> [<swy_install_dir>/swy] [const1=value1] [const2=value2] ...
#	Added var value can begin with '[' this permits ranges such as [4-6]
#
# Updated 13 Dec 2005
#	Fixed bug with unknown vars (such as $f intended for a shell script)
#	Now cli_validate passes unknown vars to command line
#
# Updated 13 Dec 2005
#	Added ability to connect to co-sim by detecting 192.168.10.1 address and using telnet access
#
# Updated Feb 2005
#	Changed to only login as normal user rather than root
#	Removed trailing "/swy" to swyprefix
#	Removed ability to connect to co-sim by detecting 192.168.10.1 address
#
#
# Updated 14 March 2006
#	Changed name to expect-lite
#	Updated usage to reflect new name
#
# Updated 11 April 2006
#	Added Dynamically assigned Vars with the first char of the line is '+'
#		Must have Parens () to capture the value of the variable
#	Usage +$myvar=not captured text (captured text)
#		+$myvar=not captured text ([a-zA-z0-9]+)
#		+$hostname=(came[a-z\-0-9]+|temp[a-z\-0-9]+)
#	Added Static Var parser which allows spaces in variable value
#
# Updated 13 April 2006 
#	Added RTL mode - multiples all timeouts by value of constant rtl
#		Specify rtl=<value> on command line (which defines the constant)
#
# Updated 3 May 2006
#	Changed expect timeout - when user sets to 0, inserts a 50 ms delay (in wait_for_prompt)
#		this prevents command line buffer overflow#
#
# Updated 16 May 2006
#	Added built-in constant $arg0 which holds expect-lite script name
#
# Updated 17 May 2006
#	Fixed bug in Dynamic Var - now \n &\r's are stripped out of var capture value
#	Added 50ms wait in Dynamic Var capture, allowing slow target to respond
# 
# Updated 18 May 2006
# 	Reworked entire Var system - now parses vars without spaces (ie. $var1$var2)
#		Also Vars are allowed in defining other static vars (ie. $var1=litteral/$var3/stuff)
# 		Vars will not be derefenced on lines starting with '#' or '+'
#
# Updated 23 May 2006
#	Fixed bug in new Var system - was not catching end of Var with chars '(' ')'
#		Added first non-var char detection (rather than last checked)
#
# Updated 25 May 2006
#	Fixed bug in new Var system - did not correctly ignore empty vars (ie. !@#$%^&*()_+-= )
#
# Updated 21 June 2006
#	Added '>>' to send line out without first waiting for a prompt. 
#		This is useful when creating text files on the fly with cat (ie. >cat > myfile.txt)
#
# Updated 7 Sept 2006
#	Added ignoring an include file named "NONE" 
#	This permits the following code using a bash if statement:
#		 >if  [ $manarch = i386 ]; then  
#		 >echo "test_include.txt"
#		 >else 
#		 >echo "" 
#		 >fi
#		 +$INCLUDE=\n([0-9a-zA-Z\._]+)
#
#		 ~$INCLUDE
#	If the variable $manarch is not set to i386, then nothing will be echoed, 
#		$INCLUDE will be set to "NONE"
#	The include action '~$INCLUDE' will now try to include the file NONE, which will be ignored, 
#	and the script will continue
#
# Updated 13 Sept 2006
#	Added Dynamic Var to be set with another Var  
#		>$search_pattern=\n([0-9a-zA-Z\._]+)
#		>+$INCLUDE=$search_pattern
#	This permits creating more generic capture files (with search_pattern set at top of test)
#
#
# Updated 3 Oct 2006
#	Added detection of coloured prompt - print message to encourage user to not use 
#	In function wait_for_prompt added '.{0,9}' to -re, which may allow coloured prompts
#
#	General clean up comments
#
#	Fixed bug with potential unbalanced parens (i.e. '<abc(def')
#		Now all parens and square-brackets are escaped if unbalanced parens 
#		or square backets are detected
#	
#	Added 10ms delay when sending lines with '>>'. This gives the remote host time to catchup.
#

