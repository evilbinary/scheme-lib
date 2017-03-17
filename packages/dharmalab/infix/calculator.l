blanks		[ \n]+
decint          [0-9]+
binint          #[bB][01]+
octint          #[oO][0-7]+
hexint          #[xX][0-9A-Fa-f]+
integer		{decint}|{binint}|{octint}|{hexint}
exponent        ([eE][+\-]?[0-9]+)
truereal	[0-9]+\.|[0-9]*\.[0-9]+{exponent}?|[0-9]+{exponent}
real		{truereal}|{integer}
imag		({decint}|{real})i
nan             \-nan\.0|\+nan\.0
inf             \-inf\.0|\+int\.0
initial         [a-zA-Z!$&:<>?_~]
subsequent      {initial}|[0-9.@]
symbol          {initial}{subsequent}*
operator	[\+\-*/%\^\\=]
comma		,
oparen		\(
cparen		\)
paren		{oparen}|{cparen}
%%
{blanks}	;; skip blanks, tabs and newlines
{imag}		(string->number (string-append "+" yytext))
{real}		(string->number yytext)
{nan}		(string->number yytext)
{inf}		(string->number yytext)
{operator}	(string->symbol yytext)
{symbol}	(string->symbol yytext)
{comma}		(string-ref "," 0)
{paren}		(string-ref yytext 0)
<<EOF>>		(list-ref '(#f) 0)
