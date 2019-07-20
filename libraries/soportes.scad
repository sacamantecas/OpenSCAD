////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// rutinas para hacer soportes
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2017 by luiso gutierrez (sacamantecas)
//
// cada módulo tiene su ejemplo simple correspondiente
// se recomienda ver qué parámetros tiene y experimentar con ellos
//


// un truco para interrogar desde fuera variables de configuración internas de este módulo
// ejemplo:
//		angulo = soportes($angulo_voladizo);
function soportes(valor) = valor; 


if ($alto_de_capa==undef) 
	echo("\n\nERROR: $alto_de_capa esta indefinido\n\n");

// Variables que se usan aquí, y puede interesar importar desde otro módulo. Para hacerlo se usa la función utilidades()
// Por ejemplo, para importar desde otro modulo $angulo_voladizo haremos:
//	angulo = utilidades($angulo_voladizo);

// $espesor=.65 ; // espesor de los tabiques de soporte (si no se especifica en el módulo llamador, se usa $espesor_defecto)
$espesor_defecto = .6 ; // es el espesor que se usará si no hay una variable $espesor declarada en el módulo principal ni se indica en la llamada 
$gro_pla_sop = 1 ; // grosor de las plataformas de soporte (con <1mm son frágiles y se rompen quedando pegadas al lado superior)
$gap_v_soporte = $alto_de_capa + .05 ; // separación entre las plataformas de soporte y lo soportado
$gap_h_soporte = 2 ; // separación horizontal de las plataformas de soporte
$angulo_voladizo = 50 ; // 45 es un nº más redondo, pero el PLA aguanta mayor ángulo


// variables que no uso con $ porque de momento no me ha interesado exportarlas (necesarias internamente pero intrascendentes cara al exterior)
alto_suela = $alto_de_capa ;
tabla_ancho = 6 * $espesor_defecto ; // esta medida determina cómo es el entablillado de base del sombrero
tabla_separa = .1 ;
mp = .1 ; // muy poco (epsilon)
refuerzo_separacion=mp/10 ; // es para forzar la separación de sombrero y parrilla (kisslicer lo agradece)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// código para probar espesores: la idea es ver qué espesor es el mejor tratado por el fileteador (no hace falta llegar a imprimir)
*	for (i=[.45:.025:.78]) {
		a=[0,0,(i-.45)*1000];
		rotate(a)
			translate([50,0,0])
				rotate(-a)
					soporte_paralelo([10,10,5], $espesor=i, sombrero=false);
	}		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// agujero_cilindrico_soportado: lo que hay que restar a una pieza para lograr un agujero cilindrico con soporte para la parte de arriba
// - cascara es para dejar hacer el soporte cerrado por ambos lados
// - anticolapso es parecido, pero sólo por un lado
// - separa es para que el soporte empiece un poco dentro (unas décimas) agrandar la parte de agujero por fuera...
// ejemplo: 
//		difference() {cube([30, 30, 40], center=true); agujero_cilindrico_soportado(20, 30, r=[90,0,0]); }
module agujero_cilindrico_soportado(d, h, t, r, cascara=0, separa=0, anticolapso) { 
	// el sistema anticolapso evita que las paredes paralelas del soporte se caigan, haciendo una U en vez de dos I	(si es >h, el soporte será macizo)
	espesor=($espesor==undef?$espesor_defecto:$espesor);
	ac = (anticolapso==undef?espesor:anticolapso);
	// RECORDAR SIEMPRE QUE ESTO ES LO QUE SE RESTA PARA CREAR UN AGUJERO CILINDRICO QUE SE VOLCARÁ HACIA LA HORIZONTAL
	// una vez fabricada la pieza, los soportes salen a trocitos y hay que refinar especialmente por abajo, pero se somete a mucho menos estrés a la pieza
	reduccion=d*cos($angulo_voladizo);

	translate(t)
		rotate(r)
			difference() {
				cylinder(d=d, h=h+mp, center=true); // el agujero es ligeramente mas largo de lo que se pide!!
				difference() {
					cylinder(d=d-2*$gap_v_soporte, h=h+(separa?-separa:mp), center=true);
					for ( signo = [ -1, 1 ])
						translate([(signo * (d/2 + reduccion)/2), 0, 0])
							cube([d/2, d, h+mp], center=true);
					if (abs(ac)<h) 
						intersection() {
							cube([(reduccion-2*espesor), d, h-2*cascara-separa+mp], center=true);
							// un voladizo de 45º lo puedo hacer con un cubo inclinado, y me ahorro hacer 2 cubos en $angulo_voladizo, o buscar el ángulo achatando
							translate([0,d/2-$gro_pla_sop-d*cos(45),ac])
								rotate([0,0,45])
									cube([d,d,h+(ac?0:mp)], center=true);
						}
				}
			}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// soporte con forma de paralelepipedo
// - hueco: separación deseable entre tabiques
// - sombrero: tapa superior del soporte
// - cascara: un envoltorio
// - suela: base para que se pegue bien a la cama (importante en soportes muy altos que pueden despegarse y caer)
// ejemplo:
//		soporte_paralelo([30, 20, 10]);
module soporte_paralelo(cubo, hueco=3, center=true, sombrero=true, cascara=false, suela=false) {	
	espesor=($espesor==undef?$espesor_defecto:$espesor);
	numhuecos = floor((cubo[0] + (hueco * .9 + espesor))/ (hueco+espesor));
	tamhueco = (cubo[0] - (numhuecos + 1) * espesor) / numhuecos;
	alto_reducido = cubo[2] - (sombrero?$gro_pla_sop+refuerzo_separacion:0);
	
	translate(center ? -cubo/2 : [0,0,0])
		if (suela)	{
			cube([cubo[0], cubo[1], alto_suela], center=false);
			translate([0,0,alto_suela+refuerzo_separacion])
				soporte_paralelo(cubo-[0,0,alto_suela+refuerzo_separacion], hueco=hueco, center=false, sombrero=sombrero, cascara=cascara, suela=false);
		} else {	
			if (cascara) {	
				union() {
					difference() {
						cube(cubo-[0,0,sombrero?$gro_pla_sop:0]);
						translate([espesor, espesor,-mp/2]) cube([cubo[0]-2*espesor, cubo[1]-2*espesor, cubo[2]+mp]);			
					}
					translate([tamhueco,espesor*3/2,0])
						soporte_paralelo([cubo[0]-tamhueco*2,cubo[1]-espesor*3,alto_reducido], hueco=hueco, center=false, sombrero=false, cascara=false);
				}
			} else {
				union () {
					union() {
						for ( i= [0:numhuecos-1]) {
							translate([i*(tamhueco+espesor), 0, 0]) cube([espesor, cubo[1], alto_reducido]);
							translate([i*(tamhueco+espesor), (i%2) * (cubo[1] - espesor), 0]) cube([tamhueco+2*espesor, espesor, alto_reducido]);
						}
					}
					translate([cubo[0]-espesor, 0, 0]) 
						cube([espesor, cubo[1], alto_reducido]);
				}	
			}
			if (sombrero)	
				translate([0,0,cubo[2]-$gro_pla_sop])
					difference() {
						cube([cubo[0], cubo[1], $gro_pla_sop]);
						{ // crear incisiones en la base del sombrero para forzar un recorrido del cabezal perpendicular al soporte en la primera capa
						tabla_num = floor((cubo[1] + tabla_separa)/ (tabla_ancho+tabla_separa));
						tabla_tam = (cubo[1] - (tabla_num - 1) * tabla_separa) / tabla_num;
						for (i=[1:tabla_num-1])
							translate([-mp/2, i * (tabla_tam+tabla_separa)-tabla_separa, -refuerzo_separacion])
								cube([cubo[0]+mp, tabla_separa, $alto_de_capa]);
						}
						
					}
		}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// estructura de soporte circular
// ejemplo:
//		soporte_circular(30, 20);
module soporte_circular(r, h, hueco=3, center=true, sombrero=true) {	
	espesor=($espesor==undef?$espesor_defecto:$espesor);
	cilindros=ceil((r- hueco/2 + hueco*.9)/(hueco+espesor));
	gap=r/(cilindros+1);
	alto_reducido=h - (sombrero?$gro_pla_sop+refuerzo_separacion:0);
	faceta= $fs*2 ; // facetas doble de grandes de lo establecido como fetén
	ancho_liston = 1.6*espesor ;
	min_separa = espesor + .1;

	
	
	// rutina para apoyar radialmente el sombrero
	module sector(angulo) {
		desde=floor((espesor+0.1)/tan(angulo/2/2)/gap);
		if (desde<cilindros) {
			sector(angulo/2);
			rotate([0,0,angulo/2]) {
				sector(angulo/2);
				translate([desde*gap-espesor-espesor/2,-ancho_liston/2,0]) 
					cube([r-desde*gap+espesor, ancho_liston, $alto_de_capa+mp]);
			}
		}
	}
	
	translate([0,0,center?-h/2:0]) {	
		translate([0,0,alto_reducido/2])
			for (i=[0:cilindros]) {
				difference() { // no puedo ceder a OpenSCAD el control de los círculos, porque si hace el exterior de 7 facetas y el interior de 6 queda fatal
					facetas = max(6, 2*3.14*(r-(gap*i))/faceta);
					cylinder(r=r-(gap*i), h=alto_reducido, center=true, $fn=facetas);
					cylinder(r=r-(gap*i)-espesor, h=alto_reducido+mp, center=true, $fn=facetas);
				}
			}
		
		if (sombrero)
			translate([0,0, alto_reducido+refuerzo_separacion]) 
				union() {
					translate([0,0, $alto_de_capa])
						cylinder(r=r, h=$gro_pla_sop - $alto_de_capa, $fn=2*3.14*r/faceta);
					difference() {
						cylinder(r=r, h=$alto_de_capa+mp, $fn=2*3.14*r/faceta);
						translate([0,0,-mp/2]) {
							cylinder(r=r-ancho_liston, h=$alto_de_capa+mp*2, $fn=2*3.14*r/faceta);
						}					
					}
					for (i=[0:5]) {
						rotate([0,0,60*i]) {
							translate([r-gap*cilindros-espesor-espesor/2,-ancho_liston/2,0]) 
								cube([gap*cilindros+espesor, ancho_liston, $alto_de_capa+mp]);
							sector(60);
						}
					}
				}
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// estructura de soporte con una forma extraña
// la idea es pedir un soporte con una forma envolvente de paralelepipedo, y pasarle como children una silueta en 2D descrita en línea o en un module independiente
// ejemplo:
//		soporte_raro([20,30,10]) { resize([20,0]) circle(d=10); }	
module soporte_raro(cubo, center=false) {
	// rutina de hacer soportes con forma rara: una silueta extruida a lo largo del eje Y
	// Se espera un children que dibuje la silueta 2D ¡¡CENTRADA!! en el plano XY
	// el cubo que se pasa como parámetro son las medidas del tarugo final: el X del children, la longitud de extrusión en Y, y el Z, que es el Y del children
	module shape() { translate([0,cubo[1]/2,0]) rotate([90,0,0]) linear_extrude(cubo[1]) children(0); }
	
	tejado=corte_a_capa(.8);
	translate(center?[0,0,0]:cubo/2)
		union() {
			difference() {
				shape() children();
				translate([0,0,-tejado]) scale([1,1.1,1]) shape() children();
			}
			intersection() {
				translate([0,0,-tejado]) 
					soporte_paralelo(cubo, sombrero=false);
				shape() children();
			}
		}
	
}	
