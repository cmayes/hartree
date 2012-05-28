lexer grammar SnapshotLexer;

// Setting filter to true drops input that doesn't match our rules.
options {
  language = Java;
  filter=true;
}

tokens { TERM; CPUTIME; DEFDATA; FUNCSET;
}

@header {
  package org.cmayes.hartree.parser.gaussian.antlr;
}

// This is Java-specific; these are context flags to avoid matching on unwanted data. 
@members {
    boolean cpuCtx = false;
    boolean termCtx = false;
    boolean multCtx = false;
    boolean freqCtx = false;
    boolean elecEngCtx = false;
    boolean defCtx = false;
    boolean zpeCtx = false;
    boolean chgCtx = false;
    boolean stoCtx = false;
    boolean dipCtx = false;
    boolean dipTotCtx = false;
    boolean g298Ctx = false;
}

// Def block

DEFOPEN: {!defCtx}? SEPDASH WS HASH { defCtx = true; $channel = HIDDEN; };
FUNCSET: {defCtx}? => ANUM SLASH FORMULA ;
SOLVENT: {defCtx}? => 'solvent=' WORD;
DEFCLOSE: {defCtx}? => SEPDASH { defCtx = false; $channel = HIDDEN; };

ZPEOPEN: 'Zero-point correction=' { zpeCtx = true; $channel = HIDDEN; };
ZPECORR: {zpeCtx}? => FLOAT { zpeCtx = false; };

G298OPEN: 'Sum of electronic and thermal Free Energies=' { g298Ctx = true; $channel = HIDDEN; };
G298: {g298Ctx}? => FLOAT { g298Ctx = false; };

// Multiplicity
MULTTAG: 'Multiplicity' { multCtx = true; $channel = HIDDEN; };
MULT: {multCtx}? => INT { multCtx = false; };

// Charge
CHARGETAG: 'Charge' WS+ '=' { chgCtx = true; $channel = HIDDEN; };
CHARGE: {chgCtx}? => INT { chgCtx = false; };

// Stoichiometry
STOITAG: 'Stoichiometry'{ stoCtx = true; $channel = HIDDEN; };
STOI: {stoCtx}? => FORMULA { stoCtx = false; };

// Dipole moment
DIPTAG: 'Dipole moment' { dipCtx = true; $channel = HIDDEN; };
DIPTOTTAG: {dipCtx}? =>  'Tot=' { dipTotCtx = true; $channel = HIDDEN; };
DIPTOT: {dipTotCtx}? => FLOAT { dipCtx = false; dipTotCtx = false; };

SCFTAG: 'SCF Done' { elecEngCtx = true; $channel = HIDDEN; };
ELECENG: {elecEngCtx}? => FLOAT { elecEngCtx = false; };

FREQTAG: 'Frequencies' { freqCtx = true; $channel = HIDDEN; } ;
FREQVAL: {freqCtx}? => FLOAT ;
REDMASS: {freqCtx}? => 'Red. masses' { freqCtx = false; $channel = HIDDEN;} ; 

// CPU time
CPUTAG: 'Job cpu time:' { cpuCtx = true; } ;
CPUDAYS: 'days' ;
CPUHOURS: 'hours' ;
CPUMINS: 'minutes' ;
CPUSECS: 'seconds.' { cpuCtx = false; } ;
CPUFLOAT: {cpuCtx}? => FLOAT ;
CPUINT: {cpuCtx}? => INT ;

// Termination date
TERMTAG: 'Normal termination of Gaussian 09 at' { termCtx = true; } ;
TERMINT: {termCtx}? => INT ;
TERMDATE: {termCtx}? => DATE ;
TERMEND: {termCtx}? => '.' { termCtx = false; } ;



fragment FLOAT: ('-')? ('0'..'9')+ '.' ('0'..'9')+ (('e'|'E'|'D'|'d') ('+'|'-')? ('0'..'9')+)? ;
fragment INT: ('-')? '0'..'9'+ ;
fragment ANUM: ('0'..'9' | 'A'..'Z' | 'a'..'z')+ ;
fragment DATE: LETTER+ WS+ LETTER+ (WS | ':' | INT)+ ;
fragment LETTER: ('a'..'z' | 'A'..'Z' | '_') ;
fragment WORD: LETTER+ ;
fragment WS: (' ' | '\t' | '\n' | '\r' | '\f')+ ;
fragment SEPDASH: '------' ;
fragment HASH: '#' ;
fragment SLASH: '/' ;
fragment FORMULA: (ANUM | '+' | '-' | '(' | ')' | ',')+ ; 