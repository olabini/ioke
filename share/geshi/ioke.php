<?php
/*************************************************************************************
 * ioke.php
 * -------
 * Author: Martin Elwin (martin@elwin.com)
 * Based on io.php by: Nigel McNie (nigel@geshi.org)
 * Copyright: (c) 2006 Nigel McNie (http://qbnz.com/highlighter/)
 * Release Version: 0\.0\.1
 * Date Started: 2009/01/09
 *
 * Ioke language file for GeSHi. Based on the standard io.php in the GeSHi
 * distribution.
 *
 * CHANGES
 * -------
 * 2009/01/09(0.0.1)
 *  -  First Release
 *
 * TODO
 * -------------------------
 *
 *************************************************************************************
 *
 *     This file is based on a part of GeSHi.
 *
 *   GeSHi is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   GeSHi is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with GeSHi; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 ************************************************************************************/

$language_data = array (  
    'LANG_NAME' => 'Ioke',
    'COMMENT_SINGLE' => array(1 => ';'),
    'CASE_KEYWORDS' => GESHI_CAPS_NO_CHANGE,
    'QUOTEMARKS' => array('"'),
    'ESCAPE_CHAR' => '\\',
    'KEYWORDS' => array(
        ),
    'SYMBOLS' => array(
'&&>>','||>>','**>>','...','===','**>','&&>','||>','->>','+>>','!>>','<>>>','<>>','&>>','%>>','#>>','@>>','/>>','*>>','?>>','|>>','^>>','~>>','$>>','=>>','<<=','>>=','<=>','<->',':::','::','=~','!~','=>','++','--','<=','>=','==','!=','&&','..','+=','-=','*=','/=','%=','&=','^=','|=','<-','+>','!>','<>','&>','%>','#>','@>','/>','*>','?>','|>','^>','~>','$>','<->','->','<<','>>','**','?|','?&','||','>','<','*','/','%','&','^','|','=','$','~','#', '-', '+'
        ),
    'CASE_SENSITIVE' => array(
        GESHI_COMMENTS => false,
        1 => false,
        2 => false,
        3 => false,
        ),
    'STYLES' => array(
      //$geshi->set_overall_style('font-family: \'DejaVu Sans Mono\', \'Bitstream Vera Sans Mono\', Consolas, \'Andale Mono WT\', \'Andale Mono\', \'Lucida Console\', \'Lucida Sans Typewriter\', \'Liberation Mono\', \'Nimbus Mono L\', Monaco, \'Courier New\', Courier, monospace; background-color: #000000; color: white;', true);
        'BACKGROUND-COLOR' => array(
             0 => 'color: #555555;'
             ),
        'KEYWORDS' => array(
            1 => 'color: #535400;',
            2 => 'color: #000000; font-weight: bold;',
            3 => 'color: #000066;'
            ),
        'COMMENTS' => array(
            1 => 'color: #4C4C4C; font-style: italic;',
            2 => 'color: #4C4C4C; font-style: italic;',
            'MULTI' => 'color: #4C4C4C; font-style: italic;'
            ),
        'ESCAPE_CHAR' => array(
            0 => 'color: #007172;'
            ),
        'BRACKETS' => array(
            0 => 'color: #333333;'
            ),
        'STRINGS' => array(
            0 => 'color: #008000;'
            ),
        'NUMBERS' => array(
            0 => 'color: #800080;'
            ),
        'SYMBOLS' => array(
            //operators
            0 => 'color: #B65B00;'
            ),
        'REGEXPS' => array(
            //positive or negative number symbol
            0 => 'color: #6D006E;',
            
            //hexadecimal numbers
            1 => 'color: #800080;',
            
            //exponential numbers
            2 => 'color: #800080;',
            
            //exponential numbers (partial)
            3 => 'color: #800080;',
            
            //operators
            4 => 'color: #3B0000;',
            
            //operators (that require space)
            5 => 'color: #3B0000;',
            
            //keywords
            6 => 'color: #000080;',
            
            //control keywords
            7 => 'color: #000080;',
            
            //function keywords
            8 => 'color: #000080;',
            
            //prototype-name keywords
            9 => 'color: #000080;',
            
            //cell-name keywords
            10 => 'color: #000080;',
            
            //kinds
            11 => 'color: #405741;',
            
            //symbols
            12 => 'color: #B65B00;',
            
            //symbols
            13 => 'color: #B65B00;',
            
            //regexp
            14 => 'color: #FF0000;',
            
            //regexp
            15 => 'color: #FF0000;'
            ),
                
            
        'SCRIPT' => array(
            0 => ''
            )
        ),
    'URLS' => array(
        1 => '',
        2 => '',
        3 => ''
        ),
    'OOLANG' => false,
    'OBJECT_SPLITTERS' => array(
        ),
    'REGEXPS' => array(
            //positive or negative number symbol 
            0 => array(
              GESHI_SEARCH  => '([+-])([[:digit:]])',
              GESHI_REPLACE => '\\1',
              GESHI_AFTER => '\\2',
            ),
            
            //hexadecimal number
            1 => array(
              GESHI_SEARCH  => '([[:digit:]]+[xX][a-fA-F0-9]+)',
              GESHI_REPLACE => '\\1',
            ),
            
            //exponential number
            2 => array(
              GESHI_SEARCH  => '([+-]?[[:digit:]][[:digit:]]*(\.[[:digit:]])?[[:digit:]]*([eE][[:digit:]]+))(\b)',
              GESHI_REPLACE => '\\1',
            ),
            
            //exponential number (partial)
            3 => array(
              GESHI_SEARCH  => '([[:digit:]][eE])',
              GESHI_REPLACE => '\\1',
            ),
            
            //operators
            4 => array(
              GESHI_SEARCH  => '([[:space:]])(\?|\!)',
              GESHI_BEFORE => '\\1',
              GESHI_REPLACE => '\\2',
            ),
            
            //operators (that require space)
            5 => array(
              GESHI_SEARCH  => '(\A|[[:space:]])(\+|\-|nand|and|xor|nor|or|::)(\Z|\b)',
              GESHI_REPLACE => '\\2',
              GESHI_BEFORE => '\\1',
              GESHI_AFTER => '\\3'
            ),
            
            //keywords
            6 => array(
              GESHI_SEARCH => '((?<![[:alnum:]!?_:])|(?<![[:alnum:]!?_:]!))(mimic|self|use|true|false|nil)(?![[:alnum:]!?_:])',
              GESHI_REPLACE => '\\2'
            ),
            
            //control keywords
            7 => array(
              GESHI_SEARCH => '((?<![[:alnum:]!?_:])|(?<![[:alnum:]!?_:]!))(return|break|continue|unless|true|false|nil)(?![[:alnum:]!?_:])',
              GESHI_REPLACE => '\\2'
            ),
            
            //function keywords
            8 => array(
              GESHI_SEARCH => '(\b)(fn|fnx|method|macro|lecro|syntax|dmacro|dlecro|dlecrox|dsyntax)(\b)',
              GESHI_BEFORE  => '\\1',
              GESHI_REPLACE => '\\2',
              GESHI_AFTER   => '\\3'
            ),
            
            //prototype-name keywords
            9 => array(
              GESHI_SEARCH => '(\b)(Base|Call|Condition|DateTime|DefaultBehavior|DefaultMacro|DefaultMethod|DefaultSyntax|Dict|FileSystem|Ground|Handler|IO|JavaMethod|LexicalBlock|LexicalMacro|List|Message|Method|Mixins|Number|Number Decimal|Number Integer|Number Rational|Number Real|Origin|Pair|Range|Regexp|Rescue|Restart|Runtime|Set|Symbol|System|Text)(\b)',
              GESHI_BEFORE  => '\\1',
              GESHI_REPLACE => '\\2',
              GESHI_AFTER   => '\\3'            ),
            
            //cell-name keywords
            10 => array(
              GESHI_SEARCH => '([(,[[:space:]`\']])(print|println|cell\?|cell|keyword|documentation|if|unless|while|until|loop|for|for:set|for:dict|bind|rescue|handle|restart|asText|inspect|notice|do|call|list|dict|set|with|kind)(\b)',
              GESHI_BEFORE  => '\\1',
              GESHI_REPLACE => '\\2',
              GESHI_AFTER   => '\\3'
            ),
            
            //kinds
            11 => array(
              GESHI_SEARCH => '(\b)([A-Z][a-z\?]+)',
              GESHI_BEFORE  => '\\1',
              GESHI_REPLACE => '\\2',
            ),
            
            //symbol symbol
            12 => array(
              GESHI_SEARCH => '(:[^\b:[:space:]]+)',
              GESHI_REPLACE => '\\1'
             // GESHI_AFTER   => '\\2'
            ),
            
            //symbol content
             13 => array(
               GESHI_SEARCH => '(:)',
//               GESHI_BEFORE  => '\\1',  
               GESHI_REPLACE => '\\1',
  //             GESHI_AFTER   => '\\3'             
            ),
            
            //regexp
            14 => array(
              GESHI_SEARCH => '(#\/.*\/[oxpniums]?)',
              GESHI_REPLACE => '\\1',
            ),
            
            //regexp
            15 => array(
              GESHI_SEARCH => '(#r\[.*\][oxpniums]?)',
              GESHI_REPLACE => '\\1',
            ),
        ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(
        ),
    'HIGHLIGHT_STRICT_BLOCK' => array(
        )
);

?>
