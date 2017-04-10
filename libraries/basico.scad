////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// utilidades y variables básicas que suelo usar
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2017 by luiso gutierrez (sacamantecas)
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
// ejemplo:
//		difference() { cube([30, 20, 20]); translate([15, 0, 10]) rotate([-90,0,0]) rosca_embutir(soportada=1); translate([15, 10,20]) rotate([180,0,0]) rosca_embutir(8) ;}
module rosca_embutir(profundidad=5, soportada=0) {
	difference() {
		union() {
			H = 4 ;	
			translate([0,0,(H-mp)/2]) cylinder(d1=5.6, d2=5.2, h=H+mp, center=true, $fn=12);
			translate([0,0,profundidad/2]) cylinder(d=3.4, h=profundidad, center=true, $fn=12);
		}
		if (soportada) {
			escala = (5.6 - 2 * $gap_v_soporte) / 5.6 ;
			translate([0,0,-$gap_h_soporte/2])
				intersection() {
					scale([escala, escala, 1])
						rosca_embutir(profundidad=0, soportada=0);
					translate([0,0,profundidad/2])
						cube([5.6 * cos($angulo_voladizo), 6, profundidad], center=true);
				}
		}
	}
}
