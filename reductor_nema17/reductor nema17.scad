/*
Usar 2 discos cicloides exige que uno mire a un lado mientras el otro mire al contrario, pero los bujes sean comunes
He probado a hacer un disco de 9 lóbulos, uno cada 40º. El otro disco debe estar desfasado medio lóbulo respecto al 1º (osea, 20º)
Si los agujeros de buje se desfasan la mitad respecto a los lóbulos (10º) entonces se pueden usar 2 discos iguales con uno girado 180º en X
Pero así las cosas, los agujeros de buje no llegan a hacerse con un círculo completo de filamento, así que son un engendro
No me queda más remedio que poner los agujeros coincidiendo con los lóbulos, y si hubiera un 2º disco tendría que tenerlos coincidiendo con los huecos
Conclusión: no veo viable usar 2 discos. Se podría plantear, pero quizá con 1 de excentricidad y bujes de 2, pero lo veo absurdo porque tampoco
   un nema17 me va a dar una velocidad tal que pueda provocar vibraciones molestas.
*/

/*
   Versión 1
- rod_entrada[D] me ha salido muy grande y sobra .2 de agujero. He corregido el ajuste de 14.40 a 14.25 pero no lo he probado
- La leva no se puede atornillar porque se abre, y si el rodamiento inferior está puesto el tornillo prisionero es inaccesible.
- Se puede pegar, poner una chaveta o atravesar un clavo. De momento he quitado el hueco de la rosca
- Los huecos M3 del cuerpo he tenido que retocarlos un poco, sobre todo uno de ellos
- El disco me ha girado bien en el 1er intento y se ha atascado en el 2º. Con un poquito de lima va muy fino

*/

use <rodamientos.scad>


// condiciones de generación
partido = 1;
ver_vitaminas = 1;
fabricar=0;
rotando=0;
$fs=.5;
$fa=.5;

$alto_de_capa=.25;
$coger_hecho=1;
caja_simple=1;
$calidad=90;
mp=.1; d=0; D=1; g=2;


// correcciones sujetas a proceso de ensayo-error
// los agujeros del disco sufren engorde natural, y el resto mórbido (ver más adelante)
function ajuste(medida) = let( correcciones=[

   [rc_bujes_d, 2.9], // bujes: interesa que vayan muy justos                               
   [sec_salida_d, 3.4], // tornillos de salida (mejor ligeramente holgados)
   [rc_bujes_d + rc_excentricidad*2, 5.9], // agujeros en el disco para empujar los bujes    
   [sec_salida_t, 6.7], // tuerca embutida de salida                                         
   [rod_entrada[d],5.45], // eje del motor, para la leva
   [rod_entrada[D],14.25], // rodamiento del eje de entrada, para la tapa del secundario       
   [rod_excentrico[d],9.6], // exterior de la leva: si sa hacen 2, una puede salir perfecta y la otra requerir algo de lima
   [rod_excentrico[D],15.15], // rodamiento de leva en el disco
   [rod_secundario[d],29.7], // interior del rodamiento de salida, no es agujero              
   [rod_secundario[D],37.3],  // exterior del rodamiento de salida                             

   0], resultado= fabricar ? correcciones[search(medida,correcciones)[0]][1] : medida)  is_undef(resultado) ? ERROR : resultado;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test de agujeros

* probar_fabricacion_agujeros();

module probar_fabricacion_agujeros() {
   module prueba(medida, exterior) { linear_extrude(3) difference() { circle(d = is_undef(exterior) ? medida + 4.2 : exterior); circle(d=medida); } }
   $fs=.1;$fa=.1;

   /* Un churrito teórico de .5 en la práctica son .6mm, con .05 de más hacia cada lado. A esto le llamo "engorde natural".
   Si pones al lado (a .5) otro churrito de .5 le faltará .05 en el lado del churrito precedente, así que va a crecer má por el lado libre. 
   Este es el "engorde mórbido" y su efecto es dramático en agujeros pequeños porque el arco interior tiene menos longitud que el 
   exterior, así que el michelín que sale es aún mayor. 
   
   Hago la fabricación en modo "Loop Order=Loop1 > Perim", que hace 1º la penúltima vuelta, y después el contorno. Da un acabado perfecto
   y sin goterones, pero provoca engorde mórbido que hay que descontar a la hora de enviar la pieza a la impresora.
   Ahora bien: algunos agujeros como los del disco cicloidal no tienen un bucle interior, y por eso tienen un engorde natural, no mórbido
*/     
   // las levas prueban rod_entrada[d] y rod_excentrico[d]
   translate([21,6]) difference() { leva(); translate([-6.5,-5,3]) cube(10);}          
   translate([21,-6]) difference() { leva(); translate([-6.5,-5,3]) cube(10);}         
   translate([5,0]) prueba(ajuste(rod_entrada[D]));       
   // esta pieza prueba rod_secundario[d], sec_salida_t y rc_bujes_d desde la medida ajustada hasta .1 más
   translate([-32,1]) linear_extrude(3) difference() { circle(d=ajuste(rod_secundario[d])); circle(d=ajuste(sec_salida_t),$fn=6); for(i=[0:5]) rotate(i*360/6+30) translate([10,0]) circle(d=ajuste(rc_bujes_d)+i*.02); }
   translate([-32,1]) prueba(ajuste(rod_secundario[D]));       
   // aquí se prueban (rc_bujes_d + rc_excentricidad*2) y rod_excentrico[D]
   translate([54,0,0]) difference() { disco_primario_girando(); translate([-20,-20,3]) cube([40,40,rc_grosor]);} 
   // probar sec_salida_d, y junto con el disco, rc_holgura_jaula
   translate([11,0,0]) difference() { cuerpo_jaula(); translate([-22,-22,3]) cube([44,44,rc_grosor]); } // el que queda orientado al NE sale pequeño, y los otros grandes
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// parámetros básicos de diseño
tornillos_nema17_d = 3;
tornillos_nema17_c_d = 5.9;
tornillos_nema17_c_h = 2;


resalte_cilindrico_nema17 = [9,22,2.5]; // un resalte que tienen mis nema17 donde está la salida del eje
rod_excentrico= roddim(6700);
rod_secundario= roddim(6706);
rod_entrada = roddim(605);

rc_holgura_jaula = .25; // prefiero holgar más de la cuenta inicialmente
rc_holgura_disco = 2 * $alto_de_capa; // holgura entre los discos y respecto a los límites
rc_rodillos = 5;
rc_diametro= 38;
rc_lobulos = 10;
rc_excentricidad = 1.5;
rc_grosor = 8;
rc_bujes_n = 5;
rc_bujes_d = 2.5;
rc_bujes_r = 11.7;
// la leva sobresale rc_hogura_disco/2 por debajo del disco y otra mitad por arriba, para que pueda derretir un poco de plástico y mantener los rodamientos en su sitio
// pero tiene un cuello añadido de longigud sec_tapa_cuello_leva para sujetar arriba el rodamiento del eje de entrada
rc_leva_h = rc_grosor + rc_holgura_disco;

// cuerpo
cue_base_se_hunde_rodamiento = 2; // coincide con el reborde que llevan la base y la tapa del secundario
cue_base_zocalo = 2; // donde apoya el rodamiento secundario para que no roce con el motor
cue_base_alto = cue_base_zocalo + rod_secundario[g] + cue_base_se_hunde_rodamiento;
cue_jaula_alto = rc_grosor + 2 * rc_holgura_disco;
cue_tapa_se_hunde_rodamiento = cue_base_se_hunde_rodamiento;
cue_tapa_reborde_h = 1;
cue_tapa_alto = cue_tapa_se_hunde_rodamiento + rod_secundario[g] + cue_tapa_reborde_h;

// secundario
sec_base_reborde_r = 1;
sec_base_reborde_h = cue_base_se_hunde_rodamiento;
sec_base_holgura_al_motor = .5; // separación entre la base del secundario y el resalte del motor
sec_base_grosor = rod_secundario[g] + sec_base_reborde_h; // aquí decido una separación del secundario con el resalte del motor
sec_base_entra_buje = cue_base_zocalo + rod_secundario[g] + sec_base_reborde_h - resalte_cilindrico_nema17[g] - sec_base_holgura_al_motor;
sec_base_hueco_eje = rod_entrada[d] +1; // si fuera rod_entrada[D] se podría poner un rod_entrada, pero sólo serviría por lo siguiente: desde el rod_entrada de arriba
   // hay un casquillo que mantiene la distancia con la leva, y quería yo poner otro casquillo desde la leva hacia abajo, pero entonces rozaría, salvo que pusiera un
   // rodamiento. Ahora bien: si la leva va firmemente sujeta al eje, no se va a mover y por tanto no necesita casquillo separador.

sec_tapa_reborde_r = sec_base_reborde_r;
sec_tapa_reborde_h = cue_tapa_se_hunde_rodamiento;
sec_tapa_reborde_ee_h = 1; // reborde que sujeta el rodamiento del eje de entrada
sec_tapa_reborde_ee_r = 1; // reborde que sujeta el rodamiento del eje de entrada
sec_tapa_grosor = rod_entrada[g] + sec_tapa_reborde_h;
sec_tapa_entra_buje = rod_secundario[g] + sec_tapa_reborde_h;
sec_tapa_cuello_leva = sec_tapa_grosor - sec_tapa_reborde_ee_h - rod_entrada[g];

sec_salida_d = 3; // diámetro tornillos para fijar la salida
sec_salida_t = 5.5/cos(30); // diámetro de la tuerca para fijar la salida
sec_salida_th = 4; // alto de la tuerca
sec_salida_n = rc_bujes_n; // nº de tornillos de salida: no hay forma de encajarlos con ángulos regulares si no están entre bujes
sec_salida_a = (360 / sec_salida_n) /2; // un ángulo puesto a ojo para no interferir con los bujes
sec_salida_r = 11.5; // excentricidad puesta a ojo para no interferir con los bujes y que la tuerca quede más o menos centrada entre los rodamientos del secundario y del eje de entrada


function Nombre_disco_stl() = str("disco(",rc_lobulos,",", rc_diametro, ",", rc_excentricidad, ",", rc_rodillos, ").stl");
function Nombre_jaula_stl() = str("jaula(",rc_lobulos,",", rc_diametro, ",", rc_excentricidad, ",", rc_rodillos, ").stl");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// exporta_disco_primario();
// exporta_hueco_jaula();


// para hacer un dibujo-guía
/*module aspa(mucho=10) {
   cube([mucho,mp,mp], center=true);
   cube([mp,mucho,mp], center=true);
   cube([mp,mp,mucho], center=true);
}*/
// para hacer una animación en planta
*let() {
   color("#50a0a0") circle(d=rod_entrada[d]+mp);
   color("#505050")
      rotate(rotando*$t * 720 / rc_lobulos)   
         linear_extrude(rc_grosor + rc_holgura_disco * 2 + sec_base_entra_buje + sec_tapa_entra_buje, convexity=10)
            sec_silueta_bujes(true);
   color("dodgerblue") disco_primario_girando();
   translate(rc_excentricidad * [-cos(rotando*$t * 720), sin(rotando*$t * 720), 0]) {
*      color("dodgerblue") aspa(2);
      rodamiento(rod_excentrico+[0,mp,0]); }
   color("#80FF80") cuerpo_jaula();
   color("#C00000") leva();
*   #translate([rc_diametro/2,0,12]) rodamiento([rc_rodillos-.66,rc_rodillos,10]);
*    aspa(7);
*   translate([42,0,0]) {
      rotate([180,0,0]) sec_tapa();
      aspa(13);
      rotate(sec_salida_a) aspa(13);
      }
}




// $vpt=[3.65,-2.20,7.37]; $vpr=[73.2,0,159.7]; $vpd=102.6; // punto de vista para hacerle la foto estando abierto y en perspectiva
// [100,0,150] a [30,0,180]


if (fabricar) {
   translate([22, 22]) {
      translate([0,0, sec_base_reborde_h]) rotate([180,0]) sec_base();
      cuerpo_base();
   }
   translate([-22, 22]) {
!      translate([0, 0, sec_tapa_grosor - sec_tapa_reborde_h]) rotate([180,0]) sec_tapa();
      translate([0, 0, cue_tapa_alto]) rotate([180,0]) cuerpo_tapa();
      arandela_sobre_leva();
   }
   translate([22,-22]) {
      cuerpo_jaula();
      for (i=[0 : 120 : 360-1])
         rotate(i) translate([rc_excentricidad+6,0]) leva();
   }
   translate([-18,-18]) disco_primario_girando();
} 
else {
   /* // vuelo de cámara programado
   pv=lookup($t, [[0.000000,0.000000],[0.002778,0.000069],[0.005556,0.000278],[0.008333,0.000625],[0.011111,0.001111],[0.013889,0.001736],[0.016667,0.002500],[0.019444,0.003403],[0.022222,0.004444],[0.025000,0.005625],[0.027778,0.006944],[0.030556,0.008403],[0.033333,0.010000],[0.036111,0.011736],[0.038889,0.013611],[0.041667,0.015625],[0.044444,0.017778],[0.047222,0.020069],[0.050000,0.022500],[0.052778,0.025069],[0.055556,0.027778],[0.058333,0.030625],[0.061111,0.033611],[0.063889,0.036736],[0.066667,0.040000],[0.069444,0.043403],[0.072222,0.046944],[0.075000,0.050625],[0.077778,0.054444],[0.080556,0.058403],[0.083333,0.062500],[0.086111,0.066736],[0.088889,0.071111],[0.091667,0.098791],[0.094444,0.126471],[0.097222,0.164286],[0.100000,0.200000],[0.102778,0.233784],[0.105556,0.265789],[0.108333,0.296154],[0.111111,0.325000],[0.113889,0.352439],[0.116667,0.378571],[0.119444,0.403488],[0.122222,0.427273],[0.125000,0.450000],[0.127778,0.471739],[0.130556,0.492553],[0.133333,0.512500],[0.136111,0.531633],[0.138889,0.550000],[0.141667,0.567647],[0.144444,0.584615],[0.147222,0.600943],[0.150000,0.616667],[0.152778,0.631818],[0.155556,0.646429],[0.158333,0.660526],[0.161111,0.674138],[0.163889,0.687288],[0.166667,0.700000],[0.169444,0.712295],[0.172222,0.724194],[0.175000,0.735714],[0.177778,0.746875],[0.180556,0.757692],[0.183333,0.768182],[0.186111,0.778358],[0.188889,0.788235],[0.191667,0.797826],[0.194444,0.807143],[0.197222,0.816197],[0.200000,0.825000],[0.202778,0.833562],[0.205556,0.841892],[0.208333,0.850000],[0.211111,0.857895],[0.213889,0.865584],[0.216667,0.873077],[0.219444,0.880380],[0.222222,0.887500],[0.225000,0.894444],[0.227778,0.901220],[0.230556,0.907831],[0.233333,0.914286],[0.236111,0.920588],[0.238889,0.926744],[0.241667,0.932759],[0.244444,0.938636],[0.247222,0.944382],[0.250000,0.950000],[0.252778,0.955495],[0.255556,0.960870],[0.258333,0.966129],[0.261111,0.971277],[0.263889,0.976316],[0.266667,0.981250],[0.269444,0.986082],[0.272222,0.987000],[0.275000,0.990000],[0.277778,0.994000],[0.280556,0.997000],[0.283333,0.999000],[0.286111,0.999000],[0.288889,0.999000],[0.291667,0.999000],[0.294444,0.999000],[0.297222,0.999000],[0.300000,0.999000],[0.302778,0.999000],[0.305556,0.999000],[0.308333,0.999000],[0.311111,0.999000],[0.313889,0.999000],[0.316667,0.999000],[0.319444,0.999000],[0.322222,0.999000],[0.325000,0.999000],[0.327778,0.999000],[0.330556,0.999000],[0.333333,0.999000],[0.336111,0.999000],[0.338889,0.999000],[0.341667,0.999000],[0.344444,0.999000],[0.347222,0.999000],[0.350000,0.999000],[0.352778,0.999000],[0.355556,0.999000],[0.358333,0.999000],[0.361111,0.999000],[0.363889,0.999000],[0.366667,0.999000],[0.369444,0.999000],[0.372222,0.999000],[0.375000,0.999000],[0.377778,0.999000],[0.380556,0.999000],[0.383333,0.999000],[0.386111,0.999000],[0.388889,0.999000],[0.391667,0.999000],[0.394444,0.999000],[0.397222,0.999000],[0.400000,0.999000],[0.402778,0.999000],[0.405556,0.999000],[0.408333,0.999000],[0.411111,0.999000],[0.413889,0.999000],[0.416667,0.999000],[0.419444,0.999000],[0.422222,0.999000],[0.425000,0.999000],[0.427778,0.999000],[0.430556,0.999000],[0.433333,0.999000],[0.436111,0.999000],[0.438889,0.999000],[0.441667,0.999000],[0.444444,0.999000],[0.447222,0.999000],[0.450000,0.999000],[0.452778,0.999000],[0.455556,0.999000],[0.458333,0.999000],[0.461111,0.999000],[0.463889,0.999000],[0.466667,0.999000],[0.469444,0.999000],[0.472222,0.999000],[0.475000,0.999000],[0.477778,0.999000],[0.480556,0.999000],[0.483333,0.999000],[0.486111,0.999000],[0.488889,0.999000],[0.491667,0.999000],[0.494444,0.999000],[0.497222,0.999000],[0.500000,0.999000],[0.502778,0.999000],[0.505556,0.999000],[0.508333,0.999000],[0.511111,0.999000],[0.513889,0.999000],[0.516667,0.999000],[0.519444,0.999000],[0.522222,0.999000],[0.525000,0.999000],[0.527778,0.999000],[0.530556,0.999000],[0.533333,0.999000],[0.536111,0.999000],[0.538889,0.999000],[0.541667,0.999000],[0.544444,0.999000],[0.547222,0.999000],[0.550000,0.999000],[0.552778,0.999000],[0.555556,0.999000],[0.558333,0.999000],[0.561111,0.999000],[0.563889,0.999000],[0.566667,0.999000],[0.569444,0.999000],[0.572222,0.999000],[0.575000,0.999000],[0.577778,0.999000],[0.580556,0.999000],[0.583333,0.999000],[0.586111,0.999000],[0.588889,0.999000],[0.591667,0.999000],[0.594444,0.999000],[0.597222,0.999000],[0.600000,0.999000],[0.602778,0.999000],[0.605556,0.999000],[0.608333,0.999000],[0.611111,0.999000],[0.613889,0.999000],[0.616667,0.999000],[0.619444,0.999000],[0.622222,0.999000],[0.625000,0.999000],[0.627778,0.999000],[0.630556,0.999000],[0.633333,0.999000],[0.636111,0.999000],[0.638889,0.999000],[0.641667,0.999000],[0.644444,0.999000],[0.647222,0.999000],[0.650000,0.999000],[0.652778,0.999000],[0.655556,0.999000],[0.658333,0.999000],[0.661111,0.999000],[0.663889,0.999000],[0.666667,0.999000],[0.669444,0.999000],[0.672222,0.999000],[0.675000,0.999000],[0.677778,0.999000],[0.680556,0.999000],[0.683333,0.999000],[0.686111,0.999000],[0.688889,0.999000],[0.691667,0.999000],[0.694444,0.999000],[0.697222,0.999000],[0.700000,0.999000],[0.702778,0.999000],[0.705556,0.999000],[0.708333,0.999000],[0.711111,0.999000],[0.713889,0.999000],[0.716667,0.999000],[0.719444,0.999000],[0.722222,0.999000],[0.725000,0.999000],[0.727778,0.999000],[0.730556,0.999000],[0.733333,0.999000],[0.736111,0.999000],[0.738889,0.999000],[0.741667,0.999000],[0.744444,0.999000],[0.747222,0.999000],[0.750000,0.999000],[0.752778,0.999000],[0.755556,0.999000],[0.758333,0.999000],[0.761111,0.999000],[0.763889,0.999000],[0.766667,0.999000],[0.769444,0.999000],[0.772222,0.999000],[0.775000,0.999000],[0.777778,0.999000],[0.780556,0.999000],[0.783333,0.999000],[0.786111,0.999000],[0.788889,0.999000],[0.791667,0.999000],[0.794444,0.999000],[0.797222,0.999000],[0.800000,0.999000],[0.802778,0.999000],[0.805556,0.999000],[0.808333,0.999000],[0.811111,0.999000],[0.813889,0.999000],[0.816667,0.999000],[0.819444,0.999000],[0.822222,0.999000],[0.825000,0.999000],[0.827778,0.999000],[0.830556,0.999000],[0.833333,0.999000],[0.836111,0.999000],[0.838889,0.999000],[0.841667,0.999000],[0.844444,0.999000],[0.847222,0.999000],[0.850000,0.999000],[0.852778,0.999000],[0.855556,0.999000],[0.858333,0.999000],[0.861111,0.999000],[0.863889,0.999000],[0.866667,0.999000],[0.869444,0.999000],[0.872222,0.999000],[0.875000,0.999000],[0.877778,0.999000],[0.880556,0.999000],[0.883333,0.999000],[0.886111,0.999000],[0.888889,0.999000],[0.891667,0.999000],[0.894444,0.999000],[0.897222,0.999000],[0.900000,0.999000],[0.902778,0.999000],[0.905556,0.999000],[0.908333,0.999000],[0.911111,0.999000],[0.913889,0.999000],[0.916667,0.999000],[0.919444,0.999000],[0.922222,0.999000],[0.925000,0.999000],[0.927778,0.999000],[0.930556,0.999000],[0.933333,0.999000],[0.936111,0.999000],[0.938889,0.999000],[0.941667,0.999000],[0.944444,0.999000],[0.947222,0.999000],[0.950000,0.999000],[0.952778,0.999000],[0.955556,0.999000],[0.958333,0.999000],[0.961111,0.999000],[0.963889,0.999000],[0.966667,0.999000],[0.969444,0.999000],[0.972222,0.999000],[0.975000,0.999000],[0.977778,0.999000],[0.980556,0.999000],[0.983333,0.999000],[0.986111,0.999000],[0.988889,0.999000],[0.991667,0.999000],[0.994444,0.999000],[0.997222,0.999000]]);
   $vpt=[.5,0,10]; $vpr=[100,0,150] + pv * [-40,0,30]; // el $vpr va cambiando con el tiempo según una pauta definida con una hoja de cálculo
   */
   // punto de vista para hacerle la foto estando abierto y en perspectiva
   $vpt=[3.65,-2.20,7.37]; $vpr=[73.2,0,159.7]; $vpd=102.6; 
   
   if (ver_vitaminas) {
      color("#50a0a0") render() nema17();
   *   %dibuja_tornillos_nema17();
      difference() {
         vitaminas_secundario();
         // la siguiente línea es para quitar un buje, que me queda feo para la imagen abierta
         if (partido) rotate(360/rc_bujes_n) translate([rc_bujes_r,0,mp]) cylinder(r=rc_bujes_d, h=cue_base_alto+cue_jaula_alto+cue_tapa_alto);
      }
      color("#bbbbbb") render(4) translate(rc_excentricidad * [-cos(rotando*$t * 720), sin(rotando*$t * 720), 0] + [0,0,cue_base_alto + rc_holgura_disco])
         rodamiento(rod_excentrico+[0,0,4]);
   }   
   translate([0,0,cue_base_alto + rc_holgura_disco]) {
      color("dodgerblue") disco_primario_girando();
      translate([0,0,-rc_holgura_disco/2]) {
         color("#C00000") leva();
         color("#fabada") translate([0,0,rc_leva_h]) arandela_sobre_leva();
      }      
   }
   render() 
      difference() { 
         secundario(); 
         translate([partido?-25:0,0,-mp]) 
            cube([50,25,25]); 
      }
   color("#FF8080") render() difference() { cuerpo_base(); translate([partido?-25:0,0,-mp]) cube([50,25,25]); }
   translate([0, 0, cue_base_alto])
      color("#80FF80") render() difference() { cuerpo_jaula(); translate([partido?-25:0,0,-mp]) cube([50,25,25]); }
   translate([0, 0, cue_base_alto+cue_jaula_alto])
      color("#8080FF") render() difference() { cuerpo_tapa(); translate([partido?-25:0,0,-mp]) cube([50,25,25]); }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// silueta externa del cuerpo
module contorno_cuerpo() {
   silueta_nema17();
}

module cuerpo_base() {
   difference() {
      linear_extrude(cue_base_alto, convexity=4)
         difference() {
            contorno_cuerpo();
            circle(d=(rod_secundario[d] + rod_secundario[D])/2);
            silueta_tornillos_nema17();
         }
      translate([0,0,cue_base_zocalo])
         cylinder(d=ajuste(rod_secundario[D]), h=cue_base_alto - cue_base_zocalo + mp);
   }
}

module cuerpo_tapa() {
   difference() {
      linear_extrude(cue_tapa_alto)
         difference() {
            contorno_cuerpo();
            circle(d = (rod_secundario[d]+rod_secundario[D])/2);
            silueta_tornillos_nema17();
         }
      translate([0,0,-mp])
         cylinder(d=ajuste(rod_secundario[D]), h=rod_secundario[g] + sec_tapa_reborde_h + mp);
      // crear un alojamiento soportado para la cabeza del tornillo
      translate([0,0,cue_tapa_alto - tornillos_nema17_c_h + $alto_de_capa])
         linear_extrude(tornillos_nema17_c_h  - $alto_de_capa + mp)
            difference() {
               silueta_tornillos_nema17(tornillos_nema17_c_d);
               if (fabricar) silueta_tornillos_nema17(ajuste(tornillos_nema17_d)+1.1);
            }
      translate([0,0,cue_tapa_alto - tornillos_nema17_c_h])
         linear_extrude($alto_de_capa+mp/10)
            silueta_tornillos_nema17(tornillos_nema17_c_d);
   }
}

module cuerpo_jaula() {
   linear_extrude(cue_jaula_alto, convexity=4)
      difference() {
         contorno_cuerpo();
         offset(rc_holgura_jaula/2)
            hueco_jaula();
         silueta_tornillos_nema17();
      }
}

module hueco_jaula() {
   if ($coger_hecho) {
      projection() import(Nombre_jaula_stl());
   } else {
      angulo = 360/(rc_lobulos + 1);
      for ( i = [0:1/$calidad:1] )
         translate(rc_excentricidad * [-cos(i * 360), sin(i * 360)])
            rotate(i * 360 / rc_lobulos)
               silueta_disco_primario($coger_hecho=1);
   }
}

module exporta_hueco_jaula() {
   $fs=.1;
   $fa=.1;
   $coger_hecho=0;
   $calidad=720;
   render()
      translate([0,0,-.5])
         linear_extrude(1)
            hueco_jaula();
   echo(str("->    ", Nombre_jaula_stl(), "    <-"));
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module dibuja_tornillos_nema17() { // tornillos del nema17, como guía
   linear_extrude(cue_base_alto + cue_jaula_alto + cue_tapa_alto +1)
      silueta_tornillos_nema17(tornillos_nema17_d);
}

// silueta, por defecto con el diámetro para hacer el agujero normal 
module silueta_tornillos_nema17(diametro=ajuste(tornillos_nema17_d)) {
      for (i=[0:90:359])
         rotate(i+45)
            translate([31/2*sqrt(2),0,0])
               circle(d= diametro);
}

module nema17() {
   hueco_rosca = 5;
   largo_motor = 40;

   cylinder(d=5, h=24); // eje
   rodamiento(resalte_cilindrico_nema17); // es un saliente que tienen mis motores
   difference() {
      translate([0,0,-largo_motor])
      linear_extrude(largo_motor)
         silueta_nema17();
      translate([0,0,-hueco_rosca])
         linear_extrude(hueco_rosca+mp)
            for (i=[0:90:359])
               rotate(i+45)
                  translate([31/2*sqrt(2),0,0])
                     circle(d=3);
   }
}

module silueta_nema17() {
   difference() {
      intersection() {
         square(42, center=true);
         circle(d=54);
      }
   }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// partes móviles: SECUNDARIO

module vitaminas_secundario() {
   color("#cccccc") render(4) 
   difference() {
      union() {
         translate([0,0,cue_base_zocalo])
            rodamiento(rod_secundario);
         translate([0,0,cue_base_alto + cue_jaula_alto + sec_tapa_reborde_h])
            rodamiento(rod_secundario);
         translate([0,0,cue_base_alto + cue_jaula_alto + cue_tapa_alto - sec_tapa_reborde_ee_h - rod_entrada[g]])
            rodamiento(rod_entrada);
      }
      translate([partido?-25:0,2,-mp]) cube([50,25,25]); 
   }

   rotate(rotando*$t * 720 / rc_lobulos)   
      translate([0,0,cue_base_alto - sec_base_entra_buje])
         color("#505050")
            linear_extrude(rc_grosor + rc_holgura_disco * 2 + sec_base_entra_buje + sec_tapa_entra_buje, convexity=10)
               sec_silueta_bujes();
}

module secundario() {
rotate(rotando*$t * 720 / rc_lobulos) {
   translate([0, 0, cue_base_zocalo + rod_secundario[g]])
      sec_base();
   translate([0, 0, cue_base_alto + cue_jaula_alto + sec_tapa_reborde_h])
      sec_tapa();
}      
}

module sec_base() { // Z=0 en el borde superior del rodamiento
   plus_para_tapar_hueco_buje = (sec_base_entra_buje < sec_base_grosor ? mp : 0);
   union() {
      // la unión de las 2 primeras piezas es exacta, sin el mp de más
      // pero poner ese mp de más luego exigiría restarlo en la parte donde está el hueco para el resalte del motor
      // y ya que funciona bien la unión sin ese exceso, ¿para qué andar dando vueltas de más?
      translate([0, 0, sec_base_reborde_h - sec_base_entra_buje ])
         linear_extrude(sec_base_entra_buje )
            difference() {
               circle(d=ajuste(rod_secundario[d]));
               sec_silueta_bujes(taladrando=true);
               circle(d=sec_base_hueco_eje);
            }
      translate([0, 0, sec_base_reborde_h - sec_base_grosor])
         linear_extrude(sec_base_grosor - sec_base_entra_buje)
            difference() {
               circle(d=ajuste(rod_secundario[d]));
               circle(d=resalte_cilindrico_nema17[D] + 2*sec_base_holgura_al_motor);
            }
      linear_extrude(sec_base_reborde_h)
         difference() {
            circle(d=rod_secundario[d] + sec_base_reborde_r*2);
            circle(d=rod_secundario[d] - 1); // -1 en vez de -mp por si ajuste(rod_secundario[d]) < (rod_secundario[d] - mp)
         }
   }
}


module sec_tapa() { // Z=0 para la base del rodamiento de salida
   difference() {
      union() {
         translate([0, 0, -mp])
            cylinder(d=ajuste(rod_secundario[d]), h=rod_secundario[g] + cue_tapa_reborde_h + mp);
         translate([0,0,-sec_tapa_reborde_h])
            cylinder(d=rod_secundario[d] + 2* sec_tapa_reborde_r, h=sec_tapa_reborde_h);
      }
      sec_salida();
      translate([0,0,-sec_tapa_reborde_h-mp])
         linear_extrude(sec_tapa_entra_buje + mp)
            sec_silueta_bujes(taladrando=true);
      translate([0,0,-sec_tapa_reborde_h - mp]) {
         cylinder(d=ajuste(rod_entrada[D]), h=sec_tapa_grosor - sec_tapa_reborde_ee_h + mp);
         cylinder(d=rod_entrada[D] - 2*sec_tapa_reborde_ee_r, h=sec_tapa_grosor+mp*2);
      }
      if (fabricar) // puesto que voy a fabricar la tapa invertida, hago unas incisiones para obligar al fileteador a que el churrito sea radial
         for (i=[0:9:359])
            rotate(i)
               translate([ajuste(rod_secundario[d])/2,-mp/2, -$alto_de_capa])
                  // podría ser dx=sec_tapa_reborde_r+1, pero es más fino rod_secundario[d]/2+sec_tapa_reborde_r - ajuste(rod_secundario[d])/2 (no hace falta entenderlo, es así y punto pelota)
                  cube([rod_secundario[d]/2+sec_tapa_reborde_r - ajuste(rod_secundario[d])/2, .05, $alto_de_capa + mp]);
   }
   if (fabricar)
      translate([0,0,$alto_de_capa])
         difference() {
            cylinder(d=rod_secundario[d] + 2* sec_tapa_reborde_r, h=rod_secundario[g] + cue_tapa_reborde_h - $alto_de_capa);
            translate([0,0,-mp])
               cylinder(d=rod_secundario[d] + 2* sec_tapa_reborde_r-1.1, h=7+2*mp);
         }
}


module sec_salida() { // Z=0 para la base del rodamiento de salida
   translate([0,0,-sec_tapa_reborde_h]) {
      linear_extrude(sec_tapa_grosor+mp)
         sec_silueta_salida()
            circle(d=ajuste(sec_salida_d));
      translate([0,0,-mp])
         difference() {
            linear_extrude(sec_salida_th+mp)
               sec_silueta_salida()
                  circle(d=ajuste(sec_salida_t), $fn=6);
         }
   }
}      


module sec_silueta_salida() {
   // es para establecer la posición de los agujeros
   for ( i= [0 : 360/sec_salida_n: 359 ])
      rotate(i + sec_salida_a)
         translate([sec_salida_r, 0])
            rotate(30) // poner las tuercas con un lado plano hacia fuera y dentro
               children();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// partes móviles: PRIMARIO

module leva() {
   // En su día hice una filigrana para poner en la leva una rosca de embutir para poner un tornillo prisionero que sujete bien la leva al eje
   // Pero resulta que apretar el tornillo requiere que los rodamientos no estén puestos. El de arriba podría estar a medias, pero el de abajo 
   // necesitaría bajar 1mm, pero no hay 1mm: sólo hay rc_holgura_disco. No se puede apretar con la leva subida y luego bajarla.
   // Además, al apretar el tornillo la leva se abre y revienta.
   // Lo propio es que la leva vaya pegada, con un vástago que atraviese el eje, o con un rebaje longitudinal en el eje y la leva, donde de meta una chaveta.
   render()   
      linear_extrude(rc_leva_h)
         difference() {         
            translate(rc_excentricidad * [-cos(rotando*$t * 720), sin(rotando*$t * 720)])
               circle(d=ajuste(rod_excentrico[d]));
            circle(d=ajuste(rod_entrada[d]));
         }
}

module arandela_sobre_leva() {
   rodamiento([ajuste(rod_entrada[d])+.1, ajuste(rod_entrada[d]) + 3, sec_tapa_cuello_leva + mp]);
}   


module sec_silueta_bujes(taladrando=false) {
   for ( i = [0: 360/rc_bujes_n: 359])
      rotate(i)
         translate([rc_bujes_r,0])
            circle(d=taladrando ? ajuste(rc_bujes_d) : rc_bujes_d);
}

module disco_primario_girando() {
   translate(rc_excentricidad * [-cos(rotando*$t * 720), sin(rotando*$t * 720)])
      rotate(rotando*$t * 720 / rc_lobulos)
         disco_primario();
}

module disco_primario() {
   linear_extrude(rc_grosor)
      difference() {
         offset(-rc_holgura_jaula/2)
            silueta_disco_primario();
         circle(d=ajuste(rod_excentrico[D]));
         for ( i = [0: 360/rc_bujes_n: 359])
            rotate(i)
               translate([rc_bujes_r,0])
                  circle(d=ajuste(rc_bujes_d + rc_excentricidad*2));
      }
}


module silueta_disco_primario() {
   if ($coger_hecho)
      projection() import(Nombre_disco_stl());
   else
      disco_cicloide(rc_lobulos, rc_diametro, rc_excentricidad, rc_rodillos);
}

module exporta_disco_primario() {
   $fs=.1;
   $fa=.1;
   $coger_hecho=0;
   $calidad=720;
   render()
      translate([0,0,-.5])
         linear_extrude(1)
            silueta_disco_primario();
   echo(str("->    ", Nombre_disco_stl(), "    <-"));
}


module disco_cicloide(lobulos, diametro, excentricidad, dp_rodillos, holgura=0) {
   almendruco = -2;
   difference() {
      epsilon = 1e-4;
      circle(d=diametro + dp_rodillos +almendruco);
      for ( i = [0 : 1/$calidad : 1-epsilon ] )
         rotate(i*360/lobulos)
            translate(excentricidad * [cos(i*360), sin(i*360)])
               for ( paso=[0 : 360/(lobulos+1) : 360-epsilon ] )
                  rotate(paso)
                     translate([diametro/2, 0])
                        circle(d=dp_rodillos + 2*holgura);
   }
}
