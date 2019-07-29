////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// rutinas de ayuda para hacer tangentes a una elipse
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2019 by luiso gutierrez (sacamantecas)
//
// cada módulo tiene su ejemplo simple correspondiente
// se recomienda ver qué parámetros tiene y experimentar con ellos
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// EJEMPLOS DE CALCULOS DE TANGENTES //////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// hacer un tarugo tangente a una elipse con un ángulo dado ////////////////////////////////////////////////////////////
* color() {
	/* planteamiento formal:
		- sea una elipse proyectada en el eje Z, con semiejes semieje_a y semieje_b y altura alto
		  y un tarugo de ancho x largo y altura alto
		- se trata de poner el tarugo de forma que su lado izquierdo toque a la elipse 
		  con un angulo dado, para lo que necesitamos las coordenadas de tangencia
	*/

	alto = 10 ;

	ancho = 45 ;
	largo = 40 ;
	angulo = 62 ;

	semieje_a = 10 ;
	semieje_b = 18 ; 

	color("red") scale([1, semieje_b/semieje_a, 1])
		cylinder(r=semieje_a, h=alto, center=true);

	// calcular X
	X = sqrt(1/(pow(semieje_b*tan(angulo)/pow(semieje_a,2),2)+1/pow(semieje_a,2))) ;
	// trasladar al punto de contacto
	translate([X, semieje_b*sqrt(1-pow(X/semieje_a,2)), 0])
		// rotar el ángulo de tangencia
		rotate([0, 0, angulo]) 
			// colocar en [0, 0, 0] el punto que debe tocar la elipse
			translate([ancho/2, 0, 0]) 
				// tarugo de partida
				cube([ancho, largo, alto], center=true);
}					

// rematar una esquina no ortogonal con una elipse /////////////////////////////////////////////////////////////////////
* color() {
	/* planteamiento formal:
		- sea un tarugo de ancho * largo, con un corte que forma con la vertical un ángulo preestablecido
		  si lo vemos desde arriba (Ctrl+4 con OpenSCAD) veremos que el lado izquierdo del tarugo mide "largo",
		  y el lado izquierdo mide "h" (a calcular en función del ángulo)
		- queremos suavizar el ángulo derecho con un óvalo de anchura arbitraria y con un grado de estiramiento 
		  tal que sea tangente al corte citado
	*/

	alto = 10 ;

	ancho = 45 ;
	largo = 40 ;
	angulo = 62 ;
		
	a = ancho/3 ; // semieje horizontal del óvalo de redondeo (este valor es arbitrario)
	h = largo-ancho/tan(angulo); // este valor es conocido o fácilmente calculable

	// cálculos: X e Y son las coordenadas de contacto, y B el semieje vertical del óvalo
	X = pow(a,2)/(a+h*tan(angulo));
	B = pow(a,2)*sqrt(1-pow(X/a,2)) / (X * tan(angulo));
	Y = B * sqrt(1 - pow(X/a, 2));

	difference() {
		translate([0, largo/2, 0])
			cube([ancho, largo, alto], center = true);
		translate([-ancho/2, largo,0])
			rotate([0,0,angulo-90])
				translate([100/2, 100/2, 0])
					cube(100, center = true);
		x_origen_ovalo = ancho/2-a ;
		difference() {
			translate([x_origen_ovalo + X + 100/2,Y-100/2,0])
				cube(100, center = true);
#			translate([x_origen_ovalo,0,0]) 
				scale([1,B/a,1.01]) cylinder(r=a, h=alto, center=true);
		}
	}
}

// uso sustractivo de la ladera ////////////////////////////////////////////////////////////////////////////////////////
* difference() {
	t=[40, 30, 10] ;
	cube(t, center=true);
	ladera(t, .4, .6, center=true, sobrado=true, $fs=.02, $fa=.02);
}	

// mostrar las consecuencias de usar valores grandes de $fa y $fs //////////////////////////////////////////////////////
 * color() {
	chicane([40, 20, 10], 5, $fs=2, $fa=12);
	#chicane([40, 20, 10.01], 5, $fs=.02, $fa=.02);
}


// construir un tarugo-chicane con laderas /////////////////////////////////////////////////////////////////////////////
* color() { 
	largo = 100 ;
	ancho = 30 ;
	alto = 20 ;

	transicion = 40 ;
	desviacion = 10 ;

	$fs = .02 ; $fa = .02 ;
	
	// uso aditivo de la ladera, volteándola para darle la orientación requerida
	translate([-(largo+transicion)/4, -desviacion/2]) 
		cube([(largo-transicion)/2, ancho, alto], center=true);
	translate([0,-ancho/2,0])	
			mirror([0,1,0])
		ladera([transicion, desviacion, alto], center=true);			
			
	// uso sustractivo de la ladera: el resultado mejora con "sobrado=true"
	difference() {
		translate([(largo-transicion)/4, desviacion/2 , 0]) 
			cube([(largo + transicion) /2, ancho, alto], center=true);
		translate([0,ancho/2,0])	
			mirror([0,1,0])
				ladera([transicion, desviacion, alto], center=true, sobrado=true);
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// MÓDULO PARA HACER LADERAS //////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// hacer una ladera en un paralelepipedo o tarugo dado
// recomiendo usar valores de $fa y $fs < .1 al menos en las llamadas a este modulo
// ejemplo:
//		ladera([30, 20, 10], $fa=.1, $fs=.1);
module ladera(tarugo, inf_x=.5, inf_y=.5, suavidad=1, sobrado=false, center=false) {
	interseccion=.1 ;
	translate([0,0,(center?-tarugo[2]/2:0) - (sobrado?interseccion:0)])
		linear_extrude(tarugo[2] + (sobrado?2*interseccion:0))
			ladera_2D(rectangulo=[tarugo[0], tarugo[1]], inf_x=inf_x, inf_z=inf_y, suavidad=suavidad, sobrado=sobrado, center=center);
}

module ladera_2D(rectangulo, inf_x=.5, inf_y=.5, suavidad=1, sobrado=false, center=false) {
/* planteamiento:
	Se trata de devolver un rectangulo de dimensiones [ rectangulo[0], rectangulo[1] ]
	recortado formando una vertiente que va de derecha a izquierda, idealmente un 
	par de curvas cóncava-convexa.
	
	El punto de inflexión se encontrará a inf_x * rectangulo[0] del lado izquierdo
	y a inf_y * rectangulo[1] del borde posterior.
	
	La inflexión tendrá un ángulo v con el eje Y que estará entre un valor máximo
	de 90º (con suavidad==0) y un valor mínimo calculado por tanteo con la función
	amin() (con suavidad==1)
	
	Como caso particular, si el punto de inflexión es posterior-izquierda tendremos
	una curva cóncava con inicio brusco y final horizontal, y si es delantero-derecha
	tendremos una curva convexa con inicio horizontal y final abrupto.
	
	El parametro "sobrado" se pone a true cuando vamos a usar la ladera de forma 
	sustractiva: mantiene las curvas calculadas para el tarugo, que se hace algo
	sobredimensionado para evitar efectos indeseables
*/	
	function acota(v, m, M)	 =  v<m ? m : (v>M ? M : v);
	function Ai2(tanu)  =  pow(tanu*Xi - Zi, 2) / (pow(tanu,2) - 2*Zi*tanu/Xi);	
	function Ad2(tanu)  =  pow(tanu*Xd - Yd, 2) / (pow(tanu,2) - 2*Yd*tanu/Xd);	
	function amin(t=45, m=0, M=90)  	// búsqueda recursiva del angulo minimo
		=  ( (Zi==0 || Ai2(tan(t))>0) && (Yd==0 || Ad2(tan(t))>0) ) 
		? ( (abs(t-m)<umbral) ? t : amin((m+t)/2, m, t) ) 
		: amin((t+M)/2, t, M);

	umbral = 1 ; // determina lo exahustivo de la búsqueda del ángulo mínimo
	interseccion=.5 ;
	exceso = [1,1] * (sobrado ? interseccion : 0);

	Xi = acota(inf_x * rectangulo[0], 0, rectangulo[0]);
	Zi = acota(inf_y * rectangulo[1], 0, rectangulo[1]);

	Xd = rectangulo[0] - Xi;
	Yd = rectangulo[1] - Zi ;

	if ( Xi>0 && Zi>0 && Xd>0 && Yd>0 || Xi+Zi==0 || Xd+Yd==0 ) 
		translate( center ? -[rectangulo[0], rectangulo[1], 0]/2 : [0,0,0] )
			union() {	
				T = tan(90 - acota(suavidad, 0, 1) * (90-amin()));
				Ai = sqrt(Ai2(T)) ;
				Ad = sqrt(Ad2(T)) ;
				Bi = Zi / (1-sqrt(1-pow((Xi>Ai?Ai:Xi)/Ai,2))) ;
				Bd = Yd / (1-sqrt(1-pow((Xd>Ad?Ad:Xd)/Ad,2))) ;
				
				intersection() {
					translate([-exceso[0], -exceso[1], 0]/2)
						square([Xi+exceso[0], rectangulo[1]+exceso[1]/2]);
					translate([0,rectangulo[1]-Bi,0]) 
						scale([1,Bi/Ai,1]) 
							circle(r=Ai);
				}
				difference() {
					translate([0, -exceso[1]/2, 0])
						square([rectangulo[0], Yd]+exceso/2);
					translate([rectangulo[0],Bd,0]) 
						scale([1,Bd/Ad,1]) 
							circle(r=Ad);
				}
			}
	else
		echo("ladera incongruente!");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// MÓDULO PARA HACER CHICANES /////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// construir una chicane de un ancho dado en un tarugo
// se recomienda jugar con el parametro suavidad en el rango [0..1]
// recomiendo usar valores de $fa y $fs < .1 al menos en las llamadas a este modulo
// ejemplo:
//		chicane([30,20, 10], 8, $fa=.05, $fs=.05);
module chicane(tarugo, ancho, inf_x=.5, inf_y=.5, suavidad=1, sobrado=false, center=false) {
	translate([0,0,center?-tarugo[2]/2:0])
		linear_extrude(tarugo[2])
			chicane_2D(rectangulo=[tarugo[0], tarugo[1]], ancho=ancho, inf_x=inf_x, inf_y=inf_y, suavidad=suavidad, sobrado=sobrado, center=center);
}

module chicane_2D(rectangulo, ancho, inf_x=.5, inf_y=.5, suavidad=1, sobrado=false, center=false) {

	function acota(v, m, M)	 =  v<m ? m : (v>M ? M : v);
	function Ai2(tanu)  =  pow(tanu*Xi - Yi, 2) / (pow(tanu,2) - 2*Yi*tanu/Xi);	
	function Ad2(tanu)  =  pow(tanu*Xd - Yd, 2) / (pow(tanu,2) - 2*Yd*tanu/Xd);	
	function amin(t=45, m=0, M=90)  	// búsqueda recursiva del angulo minimo
		=  ( (Yi==0 || Ai2(tan(t))>0) && (Yd==0 || Ad2(tan(t))>0) ) 
		? ( (abs(t-m)<umbral) ? t : amin((m+t)/2, m, t) ) 
		: amin((t+M)/2, t, M);

	if ($fa>.1 || $fs>.1) echo("CHICANE: EL RESULTADO PUEDE SER DESASTROSO CON $fa Y/O $fs >0.1");
		
	umbral = 1 ; // determina lo exahustivo de la búsqueda del ángulo mínimo

	Xi = acota(inf_x * rectangulo[0], 0, rectangulo[0]);
	Yi = acota(inf_y * (rectangulo[1] - ancho), 0, rectangulo[1] - ancho) ;

	Xd = rectangulo[0] - Xi;
	Yd = rectangulo[1] - ancho - Yi ;

	sc = ancho/2 ; // se usa mucho
	interseccion=.1 ;
	lamina = .01 ;
	exceso = [1,1,1] * (sobrado ? interseccion : 0);
	
	
	if ( Xi>0 && Yi>0 && Xd>0 && Yd>0 || Xi+Yi==0 || Xd+Yd==0 ) 
		translate( center ? -[rectangulo[0],rectangulo[1],0]/2 : [0,0,0] ) {	
			angulo = 90 - acota(suavidad, 0, 1) * (90-amin()) ;
			T = tan(angulo);
			Ai = sqrt(Ai2(T)) ;
			Ad = sqrt(Ad2(T)) ;
			Bi = Yi / (1-sqrt(1-pow((Xi>Ai?Ai:Xi)/Ai,2))) ;
			Bd = Yd / (1-sqrt(1-pow((Xd>Ad?Ad:Xd)/Ad,2))) ;

			difference() {
				offset(delta=(ancho-lamina)/2) {
					difference() {
						translate([0,rectangulo[1]-(Bi+ancho/2),0]) 
							scale([1,(Bi+lamina/2)/(Ai+lamina/2),1]) 
								circle(r=Ai + lamina/2);
						translate([0,rectangulo[1]-(Bi+ancho/2),0]) 
							scale([1,(Bi-lamina/2)/(Ai-lamina/2),1]) 
								circle(r=Ai-lamina/2);
						translate([-interseccion/2,Yd+ancho/2-(Bi*2+ancho),0])
							square([Ai+ancho/2+interseccion, Bi*2+ancho]);
						translate([-(Ai+ancho/2)-interseccion,rectangulo[1] - (Bi*2+ancho),0])
							square([Ai+ancho/2+interseccion, Bi*2+ancho]);
					}
					difference() {
						translate([rectangulo[0],(Bd+ancho/2),0]) 
							scale([1,(Bd+lamina/2)/(Ad+lamina/2),1]) 
								circle(r=Ad + lamina/2);
						translate([rectangulo[0],(Bd+ancho/2),0]) 
							scale([1,(Bd-lamina/2)/(Ad-lamina/2),1]) 
								circle(r=Ad - lamina/2);
						translate([rectangulo[0]-(Ad+ancho/2+interseccion),Yd+ancho/2,0])
							square([Ad+ancho/2+interseccion, Bd*2+ancho]);
						translate([rectangulo[0],0,0])
							square([Ad+ancho/2+interseccion, Bd*2+ancho]);
					}
				}
				translate([-(ancho+interseccion+(sobrado?interseccion:0)), 0, 0])
					square([ancho+interseccion, rectangulo[1]+interseccion]);
				translate([rectangulo[0]+(sobrado?interseccion:0), -interseccion], 0)
					square([ancho+interseccion, rectangulo[1]+interseccion]);
			}
		}	
	else
		echo("chicane incongruente!");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// MÓDULO PARA HACER TRANSICIONES /////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// construir una transición desde (0,0) al objetivo marcado, al que debe llegar con el ángulo indicado.
// el parámetro "sobra" se puede usar para extender un poco los bordes rectos, para facilitar las uniones
// ejemplo:
//		transicion_2D([20, 35], angulo=36);

module transicion_2D(objetivo, angulo=0, sobra=0, center=false) {
	
	module inviable() { echo("ERROR: TRANSICION INVIABLE!"); }
	
	nada = 1e-6;
	exceso = [1,1] * sobra;

	if ( objetivo[0]>0 && objetivo[1]>0 ) 
		translate( center ? objetivo/-2 : [0,0] ) {
			T = tan(90-(angulo<nada ? nada : angulo));	
			B = sqrt(pow(T*objetivo[1] - objetivo[0], 2) / (pow(T,2) - 2*objetivo[0]*T/objetivo[1])) ;
			A = objetivo[0] / (1-sqrt(1-pow((objetivo[1]>B?B:objetivo[1])/B,2))) ;
			if (A+0==A && B+0==B) {
				intersection() {
					translate(-exceso/2)
						square(objetivo + exceso);
					translate([A,0]) 
						scale([1,B/A,1]) 
							circle(r=A);
				}
			} else  
				inviable();
		}
	else 
		inviable();
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
