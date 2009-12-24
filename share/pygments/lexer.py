#add IokeLexer to __all__ at the top of agile.py like so:
__all__ = ['PythonLexer', 'PythonConsoleLexer', 'PythonTracebackLexer',
           'RubyLexer', 'RubyConsoleLexer', 'PerlLexer', 'LuaLexer',
           'MiniDLexer', 'IoLexer', 'IokeLexer',  'TclLexer', 'ClojureLexer',
           'Python3Lexer', 'Python3TracebackLexer']

#Then insert the following IokeLexer with the other class definitions:
class IokeLexer(RegexLexer):
    """
    For `Ioke <http://ioke.org/>`_ (a strongly typed, dynamic,
    prototype based programming language) source.

    """
    name = 'Ioke'
    filenames = ['*.ik']
    aliases = ['ioke', 'ik']
    mimetypes = ['text/x-iokesrc']
    tokens = {
        'interpolatableText': [
            (r'(\\b|\\e|\\t|\\n|\\f|\\r|\\"|\\\\|\\#|\\\Z|\\u[0-9a-fA-F]{1,4}|\\[0-3]?[0-7]?[0-7])', String.Escape),
            (r'#{', Punctuation, 'textInterpolationRoot')
            ],

        'text': [
            (r'(?<!\\)"', String, '#pop'),
            include('interpolatableText'),
            (r'[^"]', String)
            ],

        'documentation': [
            (r'(?<!\\)"', String.Doc, '#pop'),
            include('interpolatableText'),
            (r'[^"]', String.Doc)
            ],

        'textInterpolationRoot': [
            (r'}', Punctuation, '#pop'),
            include('root')
            ],

        'slashRegexp': [
            (r'(?<!\\)/[oxpniums]*', String.Regex, '#pop'),
            include('interpolatableText'),
            (r'\\/', String.Regex),
            (r'[^/]', String.Regex)
            ],

        'squareRegexp': [
            (r'(?<!\\)][oxpniums]*', String.Regex, '#pop'),
            include('interpolatableText'),
            (r'\\]', String.Regex),
            (r'[^\]]', String.Regex)
            ],

        'squareText': [
            (r'(?<!\\)]', String, '#pop'),
            include('interpolatableText'),
            (r'[^\]]', String)
            ],

        'root': [
            (r'\n', Text),
            (r'\s+', Text),

            # Comments
            (r';(.*?)\n', Comment),
            (r'\A#!(.*?)\n', Comment),

            #Regexps
            (r'#/', String.Regex, 'slashRegexp'),
            (r'#r\[', String.Regex, 'squareRegexp'),

            #Symbols
            (r':[a-zA-Z0-9_!:?]+', String.Symbol),
            (r'[a-zA-Z0-9_!:?]+:(?![a-zA-Z0-9_!?])', String.Other),
            (r':"(\\\\|\\"|[^"])*"', String.Symbol),

            #Documentation
            (r'((?<=fn\()|(?<=fnx\()|(?<=method\()|(?<=macro\()|(?<=lecro\()|(?<=syntax\()|(?<=dmacro\()|(?<=dlecro\()|(?<=dlecrox\()|(?<=dsyntax\())[\s\n\r]*"', String.Doc, 'documentation'),

            #Text
            (r'"', String, 'text'),
            (r'#\[', String, 'squareText'),

            #Mimic
            (r'[a-zA-Z0-9_][a-zA-Z0-9!?_:]+(?=\s*=.*mimic\s)', Name.Entity),

            #Assignment
            (r'[a-zA-Z_][a-zA-Z0-9_!:?]*(?=[\s]*[+*/-]?=[^=].*($|\.))', Name.Variable),

            # keywords
            (r'(break|cond|continue|do|ensure|for|for:dict|for:set|if|let|loop|p:for|p:for:dict|p:for:set|return|unless|until|while|with)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            # Origin
            (r'(eval|mimic|print|println)(?![a-zA-Z0-9!:_?])', Keyword),

            # Base
            (r'(cell\?|cellNames|cellOwner\?|cellOwner|cells|cell|documentation|hash|identity|mimic|removeCell\!|undefineCell\!)(?![a-zA-Z0-9!:_?])', Keyword),

            # Ground
            (r'(stackTraceAsText)(?![a-zA-Z0-9!:_?])', Keyword),

            #DefaultBehaviour Literals
            (r'(dict|list|message|set)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            #DefaultBehaviour Case
            (r'(case|case:and|case:else|case:nand|case:nor|case:not|case:or|case:otherwise|case:xor)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            #DefaultBehaviour Reflection
            (r'(asText|become\!|derive|freeze\!|frozen\?|in\?|is\?|kind\?|mimic\!|mimics|mimics\?|prependMimic\!|removeAllMimics\!|removeMimic\!|same\?|send|thaw\!|uniqueHexId)(?![a-zA-Z0-9!:_?])', Keyword),

            #DefaultBehaviour Aspects
            (r'(after|around|before)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            # DefaultBehaviour
            (r'(kind|cellDescriptionDict|cellSummary|genSym|inspect|notice)(?![a-zA-Z0-9!:_?])', Keyword),
            (r'(use|destructuring)', Keyword.Reserved),

            #DefaultBehavior BaseBehavior
            (r'(cell\?|cellOwner\?|cellOwner|cellNames|cells|cell|documentation|identity|removeCell!|undefineCell)(?![a-zA-Z0-9!:_?])', Keyword),

            #DefaultBehavior Internal
            (r'(internal:compositeRegexp|internal:concatenateText|internal:createDecimal|internal:createNumber|internal:createRegexp|internal:createText)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            #DefaultBehaviour Conditions
            (r'(availableRestarts|bind|error\!|findRestart|handle|invokeRestart|rescue|restart|signal\!|warn\!)(?![a-zA-Z0-9!:_?])', Keyword.Reserved),

            # constants
            (r'(nil|false|true)(?![a-zA-Z0-9!:_?])', Name.Constant),

            # names
            (r'(Arity|Base|Call|Condition|DateTime|Aspects|Pointcut|Assignment|BaseBehavior|Boolean|Case|AndCombiner|Else|NAndCombiner|NOrCombiner|NotCombiner|OrCombiner|XOrCombiner|Conditions|Definitions|FlowControl|Internal|Literals|Reflection|DefaultMacro|DefaultMethod|DefaultSyntax|Dict|FileSystem|Ground|Handler|Hook|IO|IokeGround|Struct|LexicalBlock|LexicalMacro|List|Message|Method|Mixins|NativeMethod|Number|Origin|Pair|Range|Reflector|Regexp|Regexp Match|Rescue|Restart|Runtime|Sequence|Set|Symbol|System|Text|Tuple)(?![a-zA-Z0-9!:_?])', Name.Builtin),

            # functions
            (ur'(generateMatchMethod|aliasMethod|\u03bb|\u028E|fnx|fn|method|dmacro|dlecro|syntax|macro|dlecrox|lecrox|lecro|syntax)(?![a-zA-Z0-9!:_?])', Name.Function),

            # Numbers
            (r'-?0[xX][0-9a-fA-F]+', Number.Hex),
            (r'-?(\d+\.?\d*|\d*\.\d+)([eE][+-]?[0-9]+)?', Number.Float),
            (r'-?\d+', Number.Integer),

            (r'#\(', Punctuation),

             # Operators
            (ur'(&&>>|\|\|>>|\*\*>>|:::|::|\.\.\.|===|\*\*>|\*\*=|&&>|&&=|\|\|>|\|\|=|\->>|\+>>|!>>|<>>>|<>>|&>>|%>>|#>>|@>>|/>>|\*>>|\?>>|\|>>|\^>>|~>>|\$>>|=>>|<<=|>>=|<=>|<\->|=~|!~|=>|\+\+|\-\-|<=|>=|==|!=|&&|\.\.|\+=|\-=|\*=|\/=|%=|&=|\^=|\|=|<\-|\+>|!>|<>|&>|%>|#>|\@>|\/>|\*>|\?>|\|>|\^>|~>|\$>|<\->|\->|<<|>>|\*\*|\?\||\?&|\|\||>|<|\*|\/|%|\+|\-|&|\^|\||=|\$|!|~|\?|#|\u2260|\u2218|\u2208|\u2209)', Operator),
            (r'(and|nand|or|xor|nor|return|import)(?![a-zA-Z0-9_!?])', Operator),

            # Punctuation
            (r'(\`\`|\`|\'\'|\'|\.|\,|@|@@|\[|\]|\(|\)|{|})', Punctuation),

            #kinds
            (r'[A-Z][a-zA-Z0-9_!:?]*', Name.Class),

            #default cellnames
            (r'[a-z_][a-zA-Z0-9_!:?]*', Name)
        ]
    }


