IOpt documentation = #[Command line processing the Ioke way.

Introduction.

  IOpt is a tool for command line option analysis. It tries to
  take advantage of Ioke's homoiconic nature, to provide a DSL
  interface and make you write less.
  
  IOpt has been influenced by similar tools like ruby's optparse,
  trying to make command line parsing as easy as possible for ioke
  programs, but still providing great degree of control over
  how options look like, and how they should be processed.

  Features:

  - Doesn't impose an option style, by default IOpt provides support 
    for unix style options (short and long), but you can easily define
    how an option looks like for your application.

  - Interface for easily creating options that will store a cell on a given
    object, or activate a value, call methods, blocks, etc.

  - Option execution priority, so that you can choose which actions
    should be handled before others (like --help or --version).
    Default priority is 0, more negative values are higher priority.

  - Support for clustered short options, eg if -x -v -f are short options
    you can feed -xvf to your program.

  - Options can take arguments directly from command line.  
    These can be any of those supported by Ioke, thus your
    options can take required arguments, optionals, keywords, and
    +rest, +:krest arguments just like any other ioke method.

  - Option Arguments can be coerced to Ioke objects.
    By default IOpt recognizes option arguments that are literals
       nil, true, false, symbols, numbers.
    It is also pretty easy to create your own coercing strategies 
    so you could for example transform "yes" or "no" to true/false,
    or something more advanced. Coercion can be customized per
    option, so that you can adapt how arguments are send to the
    action.
    

Basic Usage

  The following is an interesting example application to show some IOpt features:

     app = Origin with(name: "app", version: "1.0", style: "none", verbosity: 1)
     app stdout = method("Default output strategy", block, block(System out))
     app withOut = app cell(:stdout)

     app loadConfig = method("Load configuration from io", io, "Reading" println)

     app outStrategy = method("Use new output strategy for file", file, append: false,
       if(file == "-", return(@withOut = @cell(:stdout)))
       @withOut = fn("New output strategy that writes to  \#{file}", block,
         ensure(
           os = if(file kind?("java:net:Socket"), os getOutputStream,
             java:io:FileOutputStream new(file, append))
           ps = java:io:PrintStream new(os, true)
           block(ps),
           ps close,
           os close)))

     app run = method("Execute the application", args,
       withOut(fn(out,
           verbosity times(i,
             out println("\#{i}: \#{name} is running \#{args inspect}, my style is \#{style}")))
     ))

     ;; Done with app implementation, now let's define it's command line options
     opt = IOpt on(app) ; app will be the receiver object to execute actions on
     opt banner = "Usage: \#{app name} [options\]"

     ; Print the opt object and exit. Highest priority option.
     opt on("-h", "--help", "HALP!", opt println. System exit) priority = -10

     ; Print the application version before any option with more positive prio.
     opt on("--version", "Print version and exit", version println) priority = -5
     
     ; An option taking one required argument, and calling app loadConfig
     opt on("-c", "--config", "Use config file", path,
       FileSystem withOpenFile(path, fn(f, self loadConfig(f))))
     
     ; Store a cell in app
     opt on("-s", "--style", "Set output style", :@style)
     
     ; increase app verbosity. takes an optional argument
     opt on("-v", "Increase verbosity", value 1,
       @verbosity += value)

     ; An option that will activate the outStrategy cell on app
     ;
     ; help string will be taken from that cell's documentation
     ; This action will take aditional arguments according to outStrategy's arity
     ;
     ; Also this action uses a custom coercing strategy to convert
     ; english yes/no and japanese hai/iie to true/false ioke objects.
     ; if output is host:port then it will be converted to a java socket.
     ;
     ; This action priority is greater than the default (0), that means
     ; it will be executed after higher (more negative) actions, thus 
     ; if the user specified --style, this action will be executing having
     ; the user specified style already set.
     opt on("-o", "--output", :outStrategy) coercing (
       english: #/^yes|no$/ => method(t, t == "yes"),
       japanese: #/^hai|iie$/ => method(t, t == "hai"),
       net: #/:\\d+$/ => method(t,
         addr = t.split(":")
         java:net:Socket new(addr first, addr second toDecimal))
     ) priority = 1

     ; will parse the command line arguments before the first --
     ; and execute the actions by order of priority.
     opt parse!(System programArguments, stopAt: "--")
     ; give app the arguments that arent options
     app run(opt programArguments)

     ;; this are example command lines for app:
     ;; app --help
     ;; app -vvvv --version -c ~/.appConfig -o -
     ;; app -v4 -o there append:yes -s xml
     ;; app -o nihon.jp:2200 --style origami
 
More Advanced Usage

  If you need more control over how options are handled, IOpt provides
  great deal of flexibility. Please read the IOpt API to get familiar with it.


  IOpt parse

    Some times you would like to process the command line actions yourself,
  maybe you want to be sure no option is given twice, or that some option
  is always required, or have mutually exclusive actions, etc. You can 
  implement all of this by obtaining an IOpt CommandLine object, that
  represents the parsed command line, including all options found, etc.
  
      cl = opt parse(argv, stopAt: "--", includeUnknownOption: false)
      unless(cl unknownOptions emtpy?, 
        error!("Unknown options: %[%s %\]" format(cl unknownOptions)))
      unless(cl include?("--required"),
        error!("The --required option must be present!"))
      once = cl options select(o, o option == "--once")
      if(once length > 1, error!("You specified --once more than once"))
      if(cl programArguments empty?,
        error!("Please provide at least one argument"))
      sendToSubProgram(cl rest) ; elements found after --
      fileOption = cl options find(o, o option == "--file")
      fileOption args positional[0\] = "IDontMindUserInput.txt"
      fileOption action priority = -99 ; set higher priority
      cl execute
  
]; documentation
  