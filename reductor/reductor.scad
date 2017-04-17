////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// reductor planetario de dos etapas
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2017 by luiso gutierrez (sacamantecas)
//
//
use <basico.scad>
use <soportes.scad>
use <tangente.scad>
use <MCAD/involute_gears.scad>

// condiciones de producción
fabricar = 0 ;
coger_hecho = 1 ;


/* metodología recomendada:
  - establecer el valor de "fabricar" según vayamos a preparar la versión de ver o la de fabricar
  - ejecutar de un tirón el "bloque de elementos", que le lleva un buen rato
  - luego ir ejecutando cada pieza por separado, que se hace muy rápido porque está todo en caché
  - guardar cada pieza con el nombre que se indica en la consola de OpenSCAD
  Una vez que se tienen los elementos hechos se puede ejecutar de un tirón el resto y luego seguir el mismo 
  método: re-ejecutar las piezas una a una y exportarlas como .STL con los nombres indicados.
  Con las piezas exportadas ya se puede hacer "coger_hecho=1"
  Para rehacer alguna pieza se puede poner asignar coger_hecho=0 en la llamada. Por ejemplo así:
	carcasa(nivel=2, $alto_de_capa = .4, coger_hecho=0);
*/
  
// bloque de elementos: planetas primario y secundario, satelite y molde de la corona, para exportar a .STL: 
*	render() {
		planeta(generar=true, $primario=true);
		planeta(generar=true, $primario=false);
		satelite(generar=true);
		molde_corona(generar=true);
	}

	
	
// hacer la unidad de reduccion primaria, exportar como "reductor_pla_primario.stl"
	color() 
		translate([0,0,fabricar ? 0 : crc_grosor[0]+mp])		
			render() 
				unidad_reduccion($primario=true); 
// hacer la unidad de reduccion secundaria, exportar como "reductor_pla_secundario.stl"
	color() 
		translate([0,0,fabricar ? 0 : crc_grosor[0]+mp+grueso_reductor+mp+crc_grosor[1]+mp])
			render() 
				unidad_reduccion(36+72, $primario=false); // rotar el planeta por estética al dibujar el previsto
// hacer transmisión primaria, exportar como "reductor_tra_primaria.stl"
	color([0,1,0.5], .6) 
		translate([0,0,fabricar?0:crc_grosor[0]+mp+grueso_reductor+M4_arandela_h])
			render() 
				transmision($primario=true); 
// hacer transmisión secundaria, exportar como "reductor_tra_secundaria.stl"
	color([0,1,0.5], .6) 
		translate([0,0,fabricar?0:crc_grosor[0]+mp+grueso_reductor+mp+crc_grosor[1]+mp+grueso_reductor+M4_arandela_h+trs_grueso])
			rotate([180, 0, rota_portasatelites(36+72)])
				render() 
					transmision($primario=false);	
// carcasa, exportar como "reductor_carcasa_0.stl", "reductor_carcasa_1.stl" y "reductor_carcasa_2.stl"
	color([0, 1, 1], .2) {		
		rotate([0,0,fabricar ? 0 : 180]) 
			render() 
				carcasa(nivel=0, $alto_de_capa = .4);
		translate([0,0,fabricar ? 0 : crc_grosor[0]+mp+grueso_reductor+mp]) 
			rotate([0,0,fabricar ? 0 : 180]) 
				render() 
					carcasa(nivel=1, $alto_de_capa = .4);
		translate([0,0,fabricar ? 0 : crc_grosor[0]+mp+grueso_reductor+mp+crc_grosor[1]+mp+grueso_reductor+mp+crc_grosor[2]]) 
			rotate([fabricar ? 0 : 180,0,0]) 
				render() 
					carcasa(nivel=2, $alto_de_capa = .4);
	}



// afinado
$fa = 4 ;
$fs = 1 ;
afeitado = .2 * fabricar;
$alto_de_capa = .25 ;
$espesor = .55 ;
holgura_churritera = .1 ;
mp = .1 ;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// parámetros del reductor /////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

circular_pitch = 340 ;
angulo_dientes = 30 ;
grueso_reductor = 10 ;
satelite = 12 ;
satelites = 5 ;
planeta = 13 ;
corona = planeta+2*satelite;
orbita_satelites_r = circular_pitch * planeta / 360  +  circular_pitch * satelite / 360 ;

rodamiento = correccion(13  +  .2 );
eje_motor_d = 12 ;
eje_motor_nucleo = 8 ;

// transmision media: trm
trm_grueso = 16 ;
trm_rebaje_salida = 6 ;
trm_rebaje_entrada_h = 4 ;
trm_rebaje_entrada_d = 2 * (circular_pitch * planeta / 360) + 1 ;

// transmision de salida: trs	
trs_grueso = 14 ; // para tornillo cónico M4x30 con tuerca autoblocante empotrada 2.75
trs_rebaje_salida = 0 ;
trs_ala_casquillo_d = correccion(29.4  +  .6) ;
trs_ala_casquillo_h = 5 + 2.5 ; // hueco para el casquillo, los tornillos de casquillo+arandela y los del planeta con la transmisión media
trs_casquillo_d = correccion(14.5  +  .5) ;
trs_tornillos_excentricidad = 11.4 ;
trs_tuerca_rodamiento_empotrar = 2.75 ;


M4_cabeza_d = correccion(7  +  .5);
M4_tuerca_d = correccion(8  +  .5);
M4_cabeza_h = 2.8 ;
M4_d = correccion(4  +  .4);
M4_arandela_h = .8 ; // esto es sólo para el inter-etapas, que se va a construir con $alto_de_capa = .4 porque no merece la pena afinar


tornillos_eje = 5 ;
tornillos_eje_excentricidad = 6.2 ;
tornillos_eje_diametro = M4_d;


// parámetros de la carcasa
crc_arandela_dz = 2 ;
crc_rodamiento_dz = [8, 0, 4] ;
crc_grosor = [crc_arandela_dz+crc_rodamiento_dz[0] + 1 , trm_grueso + M4_arandela_h, 24.8];
crc_hueco_z = [1.2  + crc_rodamiento_dz[0], -mp/2, crc_grosor[2]-19.2];

cuerpo_lado = 85 ;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// el nº dientes según https://woodgears.ca es corona = 2 * satelite + planeta
// la relación será planeta / (corona + planeta) 
// para que los satélites sean equidistantes, (corona + planeta) / nºsatelites debe ser entero
function incremento_radio_corona(cuanto) = 360 * cuanto / corona;
function rota_portasatelites(rota_planeta) =  rota_planeta *  planeta/(corona+planeta);
$primario=undef;




module transmision() {
	petalo_d = rodamiento + 4.3 ;
	entrepetalo_d = 14 ;
	entre_circulos = (petalo_d+entrepetalo_d)/2 ;
	entre_petalos_r = orbita_satelites_r*cos(360/satelites/2)+sqrt(pow(entre_circulos, 2)-pow(orbita_satelites_r*sin(360/satelites/2), 2));

	module flor_2D_quita(merma=0, agujero_d=M4_d, fn) {
		for (i=[1:satelites])
			rotate([0, 0, (i+.5)*360/satelites]) {
				translate([entre_petalos_r, 0])
					circle(d=entrepetalo_d+merma);	
				rotate([0,0,180/satelites])
					translate([orbita_satelites_r, 0])
						circle(d=agujero_d + merma, $fn=(fn==undef?$fn:fn) );
			}
	}

	module flor_2D(merma=0) {
		difference() {
			union() {
				circle(r=sqrt(pow(orbita_satelites_r, 2)+pow(petalo_d/2, 2)-petalo_d*orbita_satelites_r*(pow(orbita_satelites_r, 2)+pow(entre_circulos, 2)-pow(entre_petalos_r, 2))/(2*orbita_satelites_r*entre_circulos)));
				for (i=[1:satelites])
					rotate([0, 0, i*360/satelites])
						translate([orbita_satelites_r, 0])
							difference() {
								circle(d=petalo_d-merma);
							}							
			}
			flor_2D_quita(merma);
		}
	}
	if (coger_hecho)
		if ($primario)
			import("piezas\\reductor_tra_primaria.stl");
		else
			import("piezas\\reductor_tra_secundaria.stl");
	else
		if ($primario==true) {
			difference() {
				union() {
					if (afeitado)
						linear_extrude($alto_de_capa) 
							flor_2D(merma=afeitado);		
					translate([0,0,afeitado ? $alto_de_capa : 0])
						linear_extrude(trm_grueso - trm_rebaje_salida - (afeitado ? $alto_de_capa : 0))
							flor_2D();

					translate([0,0,trm_grueso-trm_rebaje_salida], $fn=90) { // igualar el nº de caras en cilindro y rotate_extrude
						cylinder(d=trm_rebaje_entrada_d+mp/10, h=trm_rebaje_salida); // anti-2-manifold
						rotate_extrude()
							translate([trm_rebaje_entrada_d/2,0])	
								ladera_2D([orbita_satelites_r -M4_cabeza_d/2 - trm_rebaje_entrada_d/2, trm_rebaje_salida], $fn=360*4);
					}
				}
				translate([0,0,trm_grueso-trm_rebaje_salida-M4_cabeza_h]) 
					linear_extrude(trm_rebaje_salida+M4_cabeza_h)
						flor_2D_quita(agujero_d=M4_tuerca_d, fn=6);
						
				tornillos_union(largo=trm_grueso);
				tornillos_union(largo=trm_rebaje_entrada_h+M4_cabeza_h, diametro=M4_cabeza_d);
				translate([0,0,-mp])
					cylinder(d=trm_rebaje_entrada_d, h=trm_rebaje_entrada_h+mp);
			}
			if (fabricar) {
				soporte_circular(r=trm_rebaje_entrada_d/2 - 1, h=trm_rebaje_entrada_h - $alto_de_capa, center=false);
				translate([0, 0, trm_rebaje_entrada_h])
					difference() {
						tornillos_union(diametro=M4_d+$espesor*2, largo = M4_cabeza_h - $alto_de_capa, sobrado=0);
						tornillos_union(diametro=M4_d, largo = M4_cabeza_h - $alto_de_capa);
					}
			}
		} else {
				difference() {
					union() {
						if (afeitado)
							linear_extrude($alto_de_capa) 
								flor_2D(merma=afeitado);		
						translate([0,0,afeitado ? $alto_de_capa : 0])
							linear_extrude(trs_grueso - trs_rebaje_salida - (afeitado ? $alto_de_capa : 0))
								flor_2D();

					}
					translate([0,0,trs_grueso - trs_ala_casquillo_h])
						cylinder(d=trs_ala_casquillo_d, h=trs_ala_casquillo_h + mp);
					translate([0,0,-mp]) {
						cylinder(d = trs_casquillo_d, h=trs_grueso + mp);
						if (afeitado)
							cylinder(d=trs_casquillo_d + 2*afeitado, h=mp+$alto_de_capa);
					}
					for ( i = [1:tornillos_eje] )
						rotate([0,0, i * (360 / tornillos_eje)]) 
							translate([trs_tornillos_excentricidad, 0, -mp]) {
								cylinder(d=M4_d, h=trs_grueso+mp);
								translate([0,0,trs_grueso-trs_ala_casquillo_h+mp])
									cylinder(d=M4_cabeza_d, h=trs_ala_casquillo_h+mp);
								if (afeitado)
									cylinder(d=M4_d + 2*afeitado, h=mp + $alto_de_capa);
							}
					translate([0,0,-mp]) {
						linear_extrude(trs_tuerca_rodamiento_empotrar+mp)
							flor_2D_quita(agujero_d=M4_tuerca_d, fn=6);
						if (afeitado)
							linear_extrude($alto_de_capa+mp)
								flor_2D_quita(agujero_d=M4_tuerca_d+2*afeitado, fn=6);
					}
				}
			if (fabricar) 
				linear_extrude(trs_tuerca_rodamiento_empotrar-$alto_de_capa)
					difference() {
						flor_2D_quita(agujero_d=M4_d + 2*$espesor);
						flor_2D_quita(agujero_d=M4_d);
					}	
		}
}



module carcasa(nivel) {
	rodamiento_d = [correccion(28  +  .3), 0, 32];
	ventana_d = [24, 0, 16] ;
	
	if (coger_hecho)
		import(str("piezas\\reductor_carcasa_", nivel, ".stl"));
	else 
		difference() {
			cuerpo_silueta(crc_grosor[nivel]);
			translate([0,0,crc_hueco_z[nivel]])
				cylinder(r=circular_pitch * corona / 360, h=crc_grosor[nivel] + mp);
			// el recorte de abajo es más alto para compensar el descuelgue del churrito, con una capa más grande por el afeitado y otra normal
			if (nivel == 1) {
				translate([0,0,-mp])
					gear (number_of_teeth=corona, circular_pitch = circular_pitch + incremento_radio_corona(.26 + afeitado), pressure_angle = 30, clearance = .2, rim_thickness = $alto_de_capa+mp, gear_thickness = $alto_de_capa+mp, involute_facets=6,	backlash = holgura_churritera);
				translate([0,0,$alto_de_capa-mp])
					gear (number_of_teeth=corona, circular_pitch = circular_pitch + incremento_radio_corona(.26), pressure_angle = 30, clearance = .2, rim_thickness = $alto_de_capa+mp, gear_thickness = $alto_de_capa+mp, involute_facets=6,	backlash = holgura_churritera);
			}
			mirror([(nivel == 2) ? 1 : 0,0,0]) {
				translate([0,0,crc_grosor[nivel] - $alto_de_capa])
					gear (number_of_teeth=corona, circular_pitch = circular_pitch + incremento_radio_corona(.26), pressure_angle = 30, clearance = .2, rim_thickness = $alto_de_capa+mp, gear_thickness = $alto_de_capa+mp, involute_facets=6,	backlash = holgura_churritera);
			}
			if (nivel!=1) {
				translate([0,0,crc_hueco_z[nivel] - crc_rodamiento_dz[nivel]])
					cylinder(d=rodamiento_d[nivel], h=crc_grosor[nivel]);
				translate([0,0,-mp/2])
					cylinder(d=ventana_d[nivel], h=crc_grosor[nivel]+mp);
			}
		}
}



module tornillos_union(largo, diametro=tornillos_eje_diametro, sobrado=mp) {
	for ( i = [1:tornillos_eje] )
		rotate([0,0, i * (360 / tornillos_eje)])
			translate([tornillos_eje_excentricidad, 0, -sobrado/2])
				cylinder(d=diametro, h=largo+sobrado);
}



module cuerpo_silueta(altura) {

	module cuerpo_silueta_2D(merma=0) {
		circulo_grande = 100 ;
		agujero_esparrago = correccion( 5  +  .5 );
		columna_esparrago = 10+2 ;
		
		module esparragos(d) {
			for ( angulo = [0, 90, 180, 270] )
				rotate([0, 0, angulo])
					translate([(cuerpo_lado-columna_esparrago)/2, (cuerpo_lado-columna_esparrago)/2])
						circle(d=d);
		}
		
		difference() {
			intersection() {
				union() {
					circle(d=circulo_grande-2*merma);
					esparragos(columna_esparrago-2*merma);
				}
				square(cuerpo_lado-2*merma, center=true);
			}
			esparragos(agujero_esparrago+2*merma);
		}
	}
	
	if (afeitado)
		linear_extrude($alto_de_capa) 
			cuerpo_silueta_2D(afeitado);
	translate([0,0,afeitado ? $alto_de_capa : 0])
		linear_extrude(altura - (afeitado ? $alto_de_capa : 0))
			cuerpo_silueta_2D();
}



module mi_engranaje(dientes, h, agujero=0, holgura=0, completo=true) {

	module semiengranaje() {		 
			gear (number_of_teeth=dientes,
				circular_pitch = circular_pitch, // constante que determina el tamaño del diente (radio_medio * 360 / dientes) y es común a todos los engranajes que se toquen entre sí
				pressure_angle = 30, // "El número de dientes de un engranaje no debe estar por debajo de 18 dientes cuando el ángulo de presión es 20º ni por debajo de 12 dientes cuando el ángulo de presión es de 25º."
				clearance = .2, // controla la profundidad del hueco más allá de donde acaba el diente que engrana en él
				gear_thickness = h/2, // grosor del anillo central de la rueda, entre el hub (cilindro que engloba el agujero del eje) y el rim (anillo interior a los dientes)
				rim_thickness = h/2, // grosor de la corona de dientes y el rim_width
				rim_width = 0, // ancho del reborde desde la base del diente hacia el centro
				hub_thickness = 0, // grosor del saliente alrededor del agujero del eje (>gear_thickness o no se considera)
				hub_diameter = 0, // diametro del saliente alrededor del agujero del eje
				bore_diameter = agujero, // agujero del eje
				circles=0, // circulos que se tallan en el anillo central de la rueda para aligerar y quizá reforzar
				involute_facets=6,// el defecto efectivo es 5, que equivale a $fn=20; con 1 va bien para experimentos rápidos
				backlash = holgura, // holgura entre dientes; se puede jugar con esto para compensar el sobredimensionado natural por desparrame de churrito				
				twist = pow(360,2) * (h/2) * tan(angulo_dientes)/(2*3.1415926535897932384626433832795*circular_pitch)/dientes );  // ángulo de diente: para velocidad lenta: 5º - 10º;  normal: 15º - 25º; elevada: 30º
			}

	if (completo)
		semiengranaje();
	mirror([0,0,1])
		semiengranaje();
}	

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// unidad de reducción /////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module satelite(generar = false) {
	function nombre()=str("elementos\\reductor_s", grueso_reductor, afeitado==0?"":"_a", ".stl" );
	if (coger_hecho && !generar)
		import(nombre());
	else {
		afeita(afeitado)
			translate([0,0,grueso_reductor/2])
				mi_engranaje(satelite, h=grueso_reductor, agujero=rodamiento, holgura=holgura_churritera);
		if (generar) {
			echo("----");
			echo(str("pulsa F6 y exporta esto como ", nombre(), " "));
			echo("----"); 
		}
	}
}

module planeta(generar = false) {
	function nombre()=str("elementos\\reductor_p", grueso_reductor, $primario ? "":str("_", tornillos_eje), afeitado==0?"":"_a", ".stl");
	if (coger_hecho && !generar)
		import(nombre());
	else {
		afeita(afeitado)
			translate([0,0,grueso_reductor/2])
				rotate([0,0,180])
					mirror([0,1,0])
						difference() {
							mi_engranaje(planeta, h=grueso_reductor, holgura=holgura_churritera);
							if ($primario) 
								translate([0,0,-(grueso_reductor+mp)/2])
									intersection() {
										cylinder(d=eje_motor_d, h=grueso_reductor+mp);
										cube([eje_motor_nucleo, eje_motor_d, 2*(grueso_reductor+mp)], center=true);
									}
							else
								translate([0,0,-grueso_reductor/2])
									tornillos_union(grueso_reductor);
						}
		if (generar) {
			echo("----");
			echo(str("pulsa F6 y exporta esto como ", nombre(), " "));
			echo("----"); 
		}
	}
}


module molde_corona(generar = false) {
	function nombre()=str("elementos\\reductor_-c", grueso_reductor, afeitado==0?"":"_a", ".stl");
	if (coger_hecho && !generar)
		import(nombre());
	else {
		translate([0,0,grueso_reductor/2])
			union() {		
				mi_engranaje(corona, h=grueso_reductor+mp, holgura=-holgura_churritera, circular_pitch=circular_pitch+incremento_radio_corona(.26)); // busco una separación entre corona y satelite igual que entre planeta y satelite, y con kisslicer nuevo no se unen
				if (afeitado)
					difference() {
						mi_engranaje(corona, h=grueso_reductor+mp, holgura=-holgura_churritera, circular_pitch=circular_pitch+incremento_radio_corona(.26 + afeitado), completo=false); // busco una separación entre corona y satelite igual que entre planeta y satelite, y con kisslicer nuevo no se unen
						translate([-cuerpo_lado/2, -cuerpo_lado/2, $alto_de_capa-grueso_reductor/2])
							cube([cuerpo_lado, cuerpo_lado, grueso_reductor]);
					}
			}			
		if (generar) {
			echo("----");
			echo(str("pulsa F6 y exporta esto como ", nombre(), " "));
			echo("----"); 
		}
	}
}

module unidad_reduccion(rotacion_planeta = 0) {
	function nombre()=str("piezas\\reductor_pla_", $primario ? "primario" : "secundario", ".stl");
	
	if (coger_hecho)
		import(nombre());
	else {
		rota_satelite=rota_portasatelites(rotacion_planeta);
		for ( i = [0 : satelites-1] )
			rotate([0,0,i*360/satelites+rota_satelite])
				translate([orbita_satelites_r, 0, 0])
					rotate([0,0,-corona/satelite*(i*360/satelites+rota_satelite)])
						satelite();
						
		rotate([0,0,rotacion_planeta])
			planeta();
		
		difference() {
			cuerpo_silueta(altura=grueso_reductor, merma=.2);
			molde_corona();
		}
	}
}
