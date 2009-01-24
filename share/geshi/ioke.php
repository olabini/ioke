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
    'COMMENT_SINGLE' => array(1 => ';', 2 => '#'),
    'COMMENT_MULTI' => array('/*' => '*/'),
    'CASE_KEYWORDS' => GESHI_CAPS_NO_CHANGE,
    'QUOTEMARKS' => array('"'),
    'ESCAPE_CHAR' => '\\',
    'KEYWORDS' => array(
        1 => array(
            'return', 'break', 'continue', 'mimic', 'self', 'use', 'fn', 'fnx', 'method', 'macro',
            'lecro', 'lecrox', 'syntax', 'dmacro', 'dlecro', 'dlecrox', 'dysntax', 'unless', 'true',
            'false', 'nil'
            ),
        2 => array(
            'print', 'println', 'cell', 'cell\?', 'documentation', 'if', 'unless', 'while',
            'until', 'loop', 'for', 'for:set', 'for:dict', 'bind', 'rescue', 'handle', 'restart',
            'asText', 'inspect', 'notice', 'do', 'call', 'list', 'dict', 'set', 'with', 'kind'
            ),
        3 => array(
            'Base', 'Call', 'Condition', 'DateTime', 'DefaultBehavior', 'DefaultMacro',
            'DefaultMethod', 'DefaultSyntax', 'Dict', 'FileSystem', 'Ground', 'Handler', 'IO',
            'JavaMethod', 'LexicalBlock', 'LexicalMacro', 'List', 'Message', 'Method', 'Mixins',
            'Number', 'Number Decimal', 'Number Integer', 'Number Rational', 'Number Real', 'Origin',
            'Pair', 'Range', 'Regexp', 'Rescue', 'Restart', 'Runtime', 'Set', 'Symbol', 'System',
            'Text'
            )
        ),
    'SYMBOLS' => array(
        '(', ')', '[', ']', '{', '}', '!', '@', '%', '&', '*', '|', '/', '<', '>'
        ),
    'CASE_SENSITIVE' => array(
        GESHI_COMMENTS => false,
        1 => false,
        2 => false,
        3 => false,
        ),
    'STYLES' => array(
        'KEYWORDS' => array(
            1 => 'color: #b1b100;',
            2 => 'color: #000000; font-weight: bold;',
            3 => 'color: #000066;'
            ),
        'COMMENTS' => array(
            1 => 'color: #808080; font-style: italic;',
            2 => 'color: #808080; font-style: italic;',
            'MULTI' => 'color: #808080; font-style: italic;'
            ),
        'ESCAPE_CHAR' => array(
            0 => 'color: #000099; font-weight: bold;'
            ),
        'BRACKETS' => array(
            0 => 'color: #66cc66;'
            ),
        'STRINGS' => array(
            0 => 'color: #ff0000;'
            ),
        'NUMBERS' => array(
            0 => 'color: #cc66cc;'
            ),
        'METHODS' => array(
            1 => 'color: #006600;',
            2 => 'color: #006600;'
            ),
        'SYMBOLS' => array(
            0 => 'color: #66cc66;'
            ),
        'REGEXPS' => array(
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
        ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(
        ),
    'HIGHLIGHT_STRICT_BLOCK' => array(
        )
);

?>
