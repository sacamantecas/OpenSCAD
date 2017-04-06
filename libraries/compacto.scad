////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// implementaciones del cubo y el cilindro para hacer más compacto el código
// (lo mantengo por no modificar fuentes viejos, pero no recomiendo su uso)
// It is licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2014-2017 by luiso gutierrez (sacamantecas)
//
// cada función tiene su ejemplo simple correspondiente
// se recomienda ver qué parámetros tiene y experimentar con ellos
//



// un truco para interrogar desde fuera variables de configuración internas de este módulo
// ejemplo:
//		re = compacto($redondeo);
function compacto(valor) = valor; 

$redondeo = 1 ; // radio de redondeo por defecto (se puede indicar otro valor en la llamada)

use <basico.scad>

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// cilindro trasladado, rotado y escalado y quizá con las aristas verticales redondeadas
module cilindro(d, h, t=[0,0,0], r=[0,0,0], s=[1,1,1]) { translate(t) rotate(r) scale(s) cylinder(d=d, h=h, center=true, $fn=fn(d*max(s[0],s[1]))); }


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// cubo trasladado, rotado y escalado y quizá con las esquinas redondeadas
// esquinas se interpreta como un conjunto de 4 bits que representan los 4 cuadrantes
// ejemplo: 
//		cubo([20,30,40], esquinas=1+4, $redondeo=4);
module cubo(c, t=[0,0,0], r=[0,0,0], s=[1,1,1], esquinas=0) { // cubo, redondeado si procede

	module extremo(esquina, redondeado) {
		if (redondeado) {
			translate(esquina-[$redondeo,$redondeo,0]) cylinder(r=$redondeo, h=c[2], center=true, $fn=fn($redondeo*2));
		} else {
			translate(esquina-[.01,.01,0]) cube([.02,.02, c[2]], center=true);
		}
	}
	module cubor() {
		esquina = [c[0]/2, c[1]/2, 0] ;
		hull() {
			extremo(esquina, (esquinas%2 == 1));
			mirror([0,1,0]) extremo(esquina, (floor(esquinas/2)%2 == 1));
			mirror([1,0,0]) { 
				mirror([0,1,0]) extremo(esquina, (floor(esquinas/4)%2 == 1));
				extremo(esquina, (esquinas/8 >= 1));
			}
		}
	}
	
	rotate(r) translate(t) scale(s) // escala respecto al origen, luego traslada, y finalmente rota respecto al origen
		if (esquinas)
			if ($redondeo > min(c[0], c[1])/2)
				intersection() {
					cube(c, center=true);
					cubor();
				}
			else
				cubor();
		else 
			cube(c, center=true);
}
