////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// utilidades y variables básicas que suelo usar
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2017 by luis gutierrez (sacamantecas)
//
// cada módulo tiene su ejemplo simple correspondiente
// se recomienda ver qué parámetros tiene y experimentar con ellos
//


// corte_a_capa(n, [por_exceso]) ajusta una altura a nº entero de capas (se espera que el llamador haya asignado valor a $alto_de_capa)
function corte_a_capa(cuanto, exceso=false) = floor((cuanto+(exceso?($alto_de_capa-.0001):0))/$alto_de_capa)*$alto_de_capa;
// correccion() sirve para remarcar el código donde se hace una corrección sobre un valor teórico para que la pieza salga perfecta en la práctica
function correccion( valor )=valor; 
// numero de facetas segun el diametro, ajustado a multiplo de 4 para casar figuras ortogonales
function fn(d) = floor(( d/$fs*3.1416+3)/4)*4 ; 



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


mp = .1 ; // muy poco


// Para ayudar a la depuración dibujando un aspa (mejor resaltada con #) en el punto actual o con una traslación a partir del mismo
// ejemplo: marcar el punto y la orientación dentro de una transformación compleja:
//		translate([20, 0, 0]) rotate([0, 0, 60]) translate([0,30,0]) rotate([0,45,0]) translate([0,0,40]) aspa();
// es pueden dibujar planos en vez de ejes, por ejemplo el plano perpendicular a Y con el eje Y (los ejes X y Z no se pintan porque quedan incluidos en el plano): 
//		aspa([0,1,0]);
module aspa(normales=[0,0,0]) {
	mucho=200 ;
	if (normales[0]) cube([mp,mucho,mucho], center=true);
	if (normales[1]) cube([mucho,mp,mucho], center=true);
	if (normales[2]) cube([mucho,mucho,mp], center=true);
	if (!(normales[1]+normales[2])) cube([mucho,mp,mp], center=true);
	if (!(normales[0]+normales[2])) cube([mp,mucho,mp], center=true);
	if (!(normales[0]+normales[1])) cube([mp,mp,mucho], center=true);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// afeitar una pieza: es un corte adelantado en la base, para ahorrarnos el afeitado posterior de la pieza
// dificilmente una transformación puede ser más lenta :(
// ejemplo:
//		afeita() cube([30, 20, 10]);
module afeita(cuanto=.25) {
	maximo=200 ;
	
	difference() {
		children();
		if (cuanto)
			minkowski() {
				difference() {
					translate([-maximo/2,-maximo/2,-mp])
						cube([maximo,maximo,$alto_de_capa+mp]);
					render()
						children();
				}
				translate([0,0,-mp])
					cylinder(r=cuanto, h=mp, $fn=4);
			}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// agujero para meter una rosca de embutir dándole un calentón con el soldador
// el soporte por defecto no se pone, y si se pone es para agujero horizontal por defecto
// ejemplo:	$fa=1;$fs=1;$alto_de_capa=.3; difference() { %cube([30, 20, 20]); translate([15, 0, 10]) rotate([-90,0,0]) rosca_embutir(soportada=1); translate([15, 10,20]) rotate([180,0,0]) rosca_embutir(8) ; translate([15, 0, 0]) rosca_embutir(soportada=1, soporte_axial=1); }
module rosca_embutir(profundidad=5, soportada=0, soporte_axial=0) {
	H = 4 ;	
	Dg = [5.6, 5.2];
	Dp = 3.4;
	ancho_churrito = .5;
	$fn=12;

	if ($alto_de_capa == undef) echo("$alto_de_capa SIN DEFINIR, ESTO NO PUEDE SALIR BIEN")	;
	
	difference() {
		union() {
			translate([0,0,(H-mp)/2]) cylinder(d1=Dg[0], d2=Dg[1], h=H+mp, center=true);
			translate([0,0,profundidad/2]) cylinder(d=Dp, h=profundidad, center=true);
		}
		if (soportada) {
			if (soporte_axial)
				translate([0, 0, -mp])				
					difference() {
						cylinder(d=Dp + 2 * ancho_churrito, h=H - $alto_de_capa + mp);
						translate([0, 0, -mp])
							cylinder(d = Dp, h=H - $alto_de_capa + 3*mp);
					}
			else {
				escala = (Dg[0] - 2 * $alto_de_capa) / Dg[0] ;
				angulo_voladizo = 60 ; // para estos tamaños se puede usar hasta 60º y lo uso para afinar el soporte, que es dificil de sacar
				translate([0,0,-1.5*0]) // un hueco horizontal de 1.5 está bien
					intersection() {
                  difference() {
                     scale([escala, escala, 1])
                        rosca_embutir(profundidad=0, soportada=0);
                     // divido el soporte por la mitad, poque no hay quien lo saque de otra manera
                     translate([0,0,profundidad/2-mp])                        
                        cube([.8,Dg[0],profundidad+mp],center=true);
                  }
						translate([0,0,profundidad/2])
							cube([Dg[0] * cos(angulo_voladizo), 6, profundidad], center=true);
					}
			}
		}
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// agujero para un tornillo M3 de <largo>mm. Tras ese largo va una tuerca, y previo a ese largo hay un hueco cilíndrico para la cabeza
// si la cabeza es cónica, el cono va a partir del origen
// ejemplo:	difference() { cube(20); translate([10, 1, 8]) rotate([-80,0]) tornillo_M3(16); }
module tornillo_M3(largo, conico=true) {
	cabeza_d = 6.7;
	cuerpo_d = 3.6;
	tuerca_d = 6/cos(30);
	tuerca_h = 3;
	tuerca_holgada = tuerca_h * 3;
	holganza_cabeza = 8;
	
	translate([0, 0, -holganza_cabeza]) cylinder(d=cabeza_d, h= holganza_cabeza + mp/10);
	if (conico) cylinder(d1=cabeza_d, d2=0, h=cabeza_d/2);
	cylinder(d=cuerpo_d, h=largo + mp/10);
	translate([0, 0, largo]) 
		cylinder(d=tuerca_d, h=tuerca_holgada, $fn=6);
}
