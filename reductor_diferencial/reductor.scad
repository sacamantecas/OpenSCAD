/*
   reductor cicloidal diferencial
   La relación es 1 / (1 - ((J1*D2)/(J2*D1)) ) a 1
   La fórmula sale de un comentario de https://www.youtube.com/channel/UCG3yn3GF6-cJHvCZNQbiN1g (Alex P)
     respondiendo a 5WED en el vídeo https://www.youtube.com/watch?v=SH46bpe1cNA de ZincBoy
     
   Ignoro de dónde sale esa fórmula, pero es acorde con las observaciones que yo había hecho probando distintas combinaciones
   
   
   Una vez montado y funcionando creo que lo peor es el anillo que hace de plantilla para colocar los tornillos que sujetan el 
   rodamiento a la jaula del secundario. Aunque se peguen los tornillos con cianocrilato + bicarbonato, no hay sitio para poner
   una buena masa de pegamento.
   Hay que buscar la forma de colocar el rodamiento atornillado previamente al secundario, y una vez encajado atornillar desde 
   abajo el primario, para lo cual debe haber un aro con tuercas pegadas en el secundario.
   Bueno, se me ocurren más diseños, pero de momento no tengo intención de hacer un reductor igual.
*/


// constantes globales
mp=.1;
d=0; D=1; g=2; 
use <rodamientos.scad>
use <soportes.scad>

// visualización-generación
$fs=.5;
$fa=1;
$alto_de_capa = .25;
ancho_churrito = .6;
$calidad=90; // iteraciones por vuelta al generar el disco cicloide y los huecos cicloides primario y secundario
$coger_hecho = 1; // para coger formas ya generadas en .stl para los discos cicloides y las jaulas donde éstos giran


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// correcciones sujetas a proceso de ensayo-error
// 
function ajustado(medida) = let( correcciones=[ // array de correcciones: variable, valor sin corregir, corrección que se suma al valor sin corregir
   //
   // ajustes para fabricar con un grosor de churrito de .6
   //
   ["arco_evitar_filo_en_leva"      , 89                          ,+36 ], // arco de corte de la leva para evitar que kisslicer haga un filo incómodo
   ["rodamiento_entrada[d]"         , rodamiento_entrada[d]       , .60], // interior de la leva
   ["rodamiento_excentrico[d]"      , rodamiento_excentrico[d]    ,-.20], // exterior de la leva
   ["rodamiento_entrada[D]"         , rodamiento_entrada[D],      , .20], // alojamiento para el rodamiento del eje de entrada
   ["rodamiento_excentrico[D]"      , rodamiento_excentrico[D]    , .20], // interior de los discos

   ["rodamiento_excentrico[D] rll"  , rodamiento_excentrico[D]    ,-.25], // relleno simulando ser un rodamiento
   ["sec_aga_rod_sec_cd"            , sec_aga_rod_sec_cd          , .06], // cabezas de los tornillos que agarran el secundario al rodamiento (con .07 logro que kisslicer deje de hacer tonterías que hace con .10)
   ["dp_holgura_jaula"              , dp_holgura_jaula            , .15], // holgura disco primario-jaula
   ["ds_holgura_jaula"              , ds_holgura_jaula            , .20], // holgura disco secundario-jaula
   ["tornillo_union_rosca"          , tornillo_union_rosca        , .50], // para hacer una rosca M3

   ["tornillo_union_cabeza"         , tornillo_union_cabeza       , .10], // cabeza cónica de un tornillo M3
   ["rodamiento_secundario[d]"      , rodamiento_secundario[d]    ,-.20], // interior del rodamiento secundario para la caja secundaria (relleno, no hueco)
   ["rodamiento_secundario[D]"      , rodamiento_secundario[D]    , .20], // exterior del rodamiento secundario para la caja primaria
   ["sec_aga_rod_sec_d"             , sec_aga_rod_sec_d           , .40], // tornillos del secundario que se atornillan al rodamiento (mejor algo holgados)
   ["aro_posidionador_tornillos_d"  , aro_posidionador_tornillos_d,-1.0], // para que la caja del secundario encaje en el aro posicionador (le doy holgura porque lleva pegamento)

   ["sec_aga_rod_sec_td"            , sec_aga_rod_sec_td          , .40], // para que entre bien la llave de tubo que aprieta las tuercas
   ["pri_aga_rod_sec_d"             , pri_aga_rod_sec_d           , .40], // tornillos que agarran el primario al rodamiento
   ["tornillo_union_pasa"           , tornillo_union_pasa         , .30], // para meter un tornillo M3
   ["tornillo_union_entra"          , tornillo_union_entra        , .30], // ajuste para que la cabeza quede como yo quiero
   ["sal_tornillo"                  , sal_tornillo                , .30], // agujero pasante para el tornillo que sujeta algo en el secundario
   
   ["sal_tuerca_d"                  , sal_tuerca_d                , .30], // tuerca embutida para atornillar lo que entre por sal_tornillo
   ["pri_aga_rod_sec_td"            , pri_aga_rod_sec_td          , .30], // tuercas embutidas abajo para los tornillos que agarran el primario al rodamiento    
   ["pri_aga_rod_sec_cd"            , pri_aga_rod_sec_cd          , .10], // cabezas de los tornillos que agarran el secundario al rodamiento para hacer el aro posicionador

   0], indice=search([medida],correcciones)[0], resultado= correcciones[indice][1] + (fabricar?correcciones[indice][2]:0))  is_undef(resultado) ? ERROR : resultado;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* test_de_precision();
module test_de_precision() {
   at = 3;
   // ajuste rodamiento_excentrico[d] con rodamiento_entrada[d] dentro y arco_evitar_filo_en_leva en la periferia
*   translate([0,-30]) {
      translate([10,0]-[6,-8]) linear_extrude(at) projection(true) leva();   
      difference() {
         linear_extrude(at) 
            difference() { 
               circle(d=ajustado("rodamiento_secundario[d]")); 
               translate([-9,0]) circle(d=ajustado("rodamiento_entrada[D]"));
               translate([-10,12.5]) circle(d=ajustado("sec_aga_rod_sec_d"));
               translate([0,12.5]) circle(d=ajustado("sec_aga_rod_sec_td"));
               translate([10,12]) circle(d=ajustado("tornillo_union_rosca"));
               translate([10,0]) circle(d=ajustado("rodamiento_excentrico[D]"));
               translate([-7,-13]) circle(d=ajustado("sec_aga_rod_sec_cd"));
               // me ahorro probar sal_tornillo porque es como tornillo_union_pasa y está probado en el tornillo de cabeza cónica
               // me ahorro probar sal_tuerca_d porque es igual que pri_aga_rod_sec_td
               // me ahorro probar tornillo_union_pasa porque es igual que sal_tornillo
               // me ahorro probar pri_aga_rod_sec_d porque es igual que sal_tornillo
               // me ahorro probar pri_aga_rod_sec_cd porque es igual que sec_aga_rod_sec_cd
               }
         translate([2,-12]) tornillo_cabeza_conica(ajustado("tornillo_union_cabeza"), ajustado("tornillo_union_pasa"), at, embutido=ajustado("tornillo_union_entra"));
      }
      linear_extrude(at) difference() { circle(d=ajustado("rodamiento_secundario[D]")+6); circle(d=ajustado("rodamiento_secundario[D]")); }
      translate([-9,0]) linear_extrude(at) difference() { 
         circle(d=ajustado("rodamiento_excentrico[D] rll"));
         circle(d=ajustado("pri_aga_rod_sec_td"), $fn=6);
      }
   }
   
   translate([41,3]) {
*      translate(-[27,-32]) aro_posicionador_tornillos_agarre();
      linear_extrude(at) projection(true) translate([excentricidad,0, -4]) disco_primario_girando();
   }
   translate([0,30])
      linear_extrude(at) {
         projection(true) 
            translate([excentricidad,0, -4]) 
               disco_secundario_girando();
         difference() { circle(d=47); offset(ajustado("dp_holgura_jaula")/2) hueco_caja_primario(); }      
      }
*   translate([-40,3]) linear_extrude(at) difference() { circle(d=42); offset(ajustado("ds_holgura_jaula")/2) hueco_caja_secundario(); } 

   // estas 2 piezas parece que se amontonan, pero es que las he hecho aparte, sólo con los 2 discos
   translate([-50,5]) linear_extrude(at) projection(true) {
      translate([0,0,(rodamiento_secundario[g]/2 + pri_hueco_sobre_rosec + pri_hueco_bajo_rosec)-primario_alto]) caja_primario();
      translate([0,0,-secundario_alto+rodamiento_secundario[g]]) caja_secundario();
   }
}
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// piezas M3
M3cil_ch=2;
M3cil_cd=5.6;
M3con_cd=6;
M3=3;
M3_th=2;
M3_tah=4;
M3_td=5.5/cos(30);


// global
excentricidad = 2;
rodamiento_entrada = roddim(606);
rodamiento_excentrico = roddim(6700);
rodamiento_secundario = roddim(6708);
abrazo_del_rod_secundario = 5.5;
eje_visto_por_secundario = 0;
separacion_entre_mitades = $alto_de_capa;

// 3 tornillos cónicos M3 unen los discos, entrando por el dp y roscando en el ds
tornillo_union_pasa = M3;
tornillo_union_rosca = 2.6;
tornillo_union_cabeza = M3con_cd;
tornillo_union_r = rodamiento_excentrico[D]/2 + 3;
tornillo_union_entra = 0;


// primario
dp_lobulos = 10;
dp_diametro = 40;
dp_rodillos = 6;
dp_grosor = 8;
dp_holgura_disco = .5; // esta holgura es por el lado de la entrada para evitar roces, y por el de salida porque la jaula secundaria es menor y hay que alejarse
dp_holgura_jaula = .1; // repartida entre el disco y la jaula, en radio
dp_reborde_rod = 2/3; // un reborde para que el rodamiento no se deslice hacia el lado de la entrada. Si es mayor, el aro separador de la leva puede rozar

pri_sujeta_roent_fuera = 1; // pestaña que sujeta el rodamiento de entrada en el lado primario
pri_sujeta_roent_dentro = .5; // un reborde para poner pegamento o fundir el plástico y que inmovilice el rodamiento
pri_hueco_sobre_rosec = 2; // reborde que sobresale por encima del rodamiento secundario para atornillarlo o pegar un aro de retención
pri_hueco_bajo_rosec = 2; // espacio que queda libre para atornillar el secundario al rodamiento por dentro
primario_alto = pri_sujeta_roent_fuera + rodamiento_entrada[g] + pri_sujeta_roent_dentro + dp_holgura_disco + dp_grosor + dp_holgura_disco + rodamiento_secundario[g] + pri_hueco_sobre_rosec + pri_hueco_bajo_rosec;

pri_apoyo_rosec = rodamiento_secundario[D] - (rodamiento_secundario[D]-rodamiento_secundario[d])/3;
aro_posidionador_tornillos_d = rodamiento_secundario[d] - 1;
aro_posidionador_tornillos_D = pri_apoyo_rosec - 1;

pri_aga_rod_sec_n = 6; // cantidad de tornillos que agarran el rodamiento secundario a la caja primaria
pri_aga_rod_sec_d = M3; // diámetro de esos tornillos
pri_aga_rod_sec_recorte=1.7; // un recorte para evitar los filos en el borde del agujero para el tornillo     
pri_aga_rod_sec_cd = M3cil_cd; // diámetro la cabeza de esos tornillos
pri_aga_rod_sec_ch = pri_hueco_sobre_rosec; // alto de la cabeza de esos tornillos (se lima si fuera necesario)
pri_aga_rod_sec_h = 25; // largo 
pri_aga_rod_sec_td = M3_td; // diámetro de la tuerca, que va colocada desde abajo
pri_aga_rod_sec_th = M3_tah + 1; // alto del hueco para la tuerca (por calcular hasta dónde hay que embutirla para que lleguen los tornillos, dada su longitud)

pri_separador_leva_d = rodamiento_entrada[d] + ancho_churrito; // un aro que hace que el eje de la leva tenga tope por abajo. Por arriba no puede porque el secundario va cerrado
pri_separador_leva_g = ancho_churrito;


// secundario
ds_lobulos = 9;
ds_diametro= 33; // ds_diametro=34 hace que los tornillos de sujección del secundario al rodamiento no queden bien rodeados
ds_rodillos= 6; // busco que los lóbulos del disco sean comparables a los rodillos
ds_grosor = 8;
ds_holgura_disco = .5; // esta holgura es por el lado de salida para evitar roces. Al lado del primario hay que hacer un aro conector que no llegue a tocar ninguna de las jaulas
ds_conector = dp_holgura_disco; // es un realce en el disco secundario para acercarse y entrar en contacto con el primario, que se queda corto para no rozar con la caja secundaria
ds_holgura_jaula = dp_holgura_jaula; // repartida entre el disco y la jaula, en radio
ds_reborde_rod = 1; 

sec_apoyo_rosec = rodamiento_secundario[d] + (rodamiento_secundario[D]-rodamiento_secundario[d])/3;
sec_sujeta_roent_fuera = 1; // grosor de la tapa del rodamiento de entrada en el lado secundario
sec_sujeta_roent_dentro = .5; // un reborde para poner pegamento o fundir el plástico y que inmovilice el rodamiento
secundario_alto = sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro + ds_holgura_disco + ds_grosor;
sec_aga_rod_sec_d = M3; // diámetro de los tornillos que sujetan la caja del secundario al rodamiento
sec_aga_rod_sec_cd = M3cil_cd;
sec_aga_rod_sec_rebaje = .18; // rebaje hecho con lima en los tornillos citados
sec_aga_rod_sec_td = 9.5; // diámetro del hueco para meter una llave que apriete las tuercas de los tornillos anteriores
sec_aga_rod_sec_th = M3_th +1.25; // profundidad a la que entran las tuercas anteriores ¡no autoblocantes!
sec_aga_rod_sec_recorte_d = 20; // las cabezas de los tornillos van pegadas al aro y hay que esquivar el pegote
sec_aga_rod_sec_recorte_x = .9; // este parámetro y el anterior van coordinados, junto con la forma de hacer el recorte

sec_aga_rod_sec_incisiones = 7; // nº de incisiones para forzar una estructura radial en lo que apoya en el soporte
sec_aga_rod_sec_gro_soporte = ancho_churrito * 3; // grosor del arete de soporte

// salida del secundario: unas tuercas embutidas para atornillar desde fuera con tornillos M3
// interfiere con los rodillos de la jaula del secundario, así que pueden ser 2, 5 o 10 si queremos simetría radial.
// una alternativa es poner roscas de embutir desde fuera, y entonces no interfiere y se pueden poner las que se quiera 
sal_cuantos = 2;                  
sal_tuerca_d = M3_td;
sal_tuerca_h = M3_tah;
sal_tornillo = tornillo_union_pasa;
sal_radio = rodamiento_entrada[D]/2 + sal_tuerca_d/2 + 1;

// para animar, con cada 360º de giro del eje de entrada los lóbulos del primario avanza al siguiente hueco
// pero para los agujeros de conexión de los discos no basta un ciclo de 360º porque dan un salto al pasar de .999 a 0
// así que el ciclo de animación completo debe ser de tantas vueltas como lóbulos tiene el disco primario
ciclo_animacion = dp_lobulos;


function Nombre_stl_pri(parte) = str(parte,"(",dp_lobulos,",", dp_diametro, ",", excentricidad, ",", dp_rodillos, ").stl");
function Nombre_stl_sec(parte) = str(parte,"(",ds_lobulos,",", ds_diametro, ",", excentricidad, ",", ds_rodillos, ").stl");
module RotacionSecundario(sentido=1) { rotate((sentido * -$t * ciclo_animacion * 360 / dp_lobulos)/((ds_lobulos + 1)/(dp_lobulos - ds_lobulos))) children(); } 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  control de lo que se dibuja  /////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


ColorCajaPrimario="#55dd77";
ColorLeva = "#C00000";
ColorEjePrimario = "#505060"; 
ColorAroPosicionador = "#ff8833";
ColorRodamientos = "#aaaaaa";

ver_abierto = 1;
ver_vitaminas = 1;
fabricar=0;

// exporta_disco_primario();
// exporta_hueco_caja_primario();
// exporta_disco_secundario();
// exporta_hueco_caja_secundario();


if ( fabricar ) { // fabricación y experimentos
   // caja_primario();
   // pri_tornillos_agarre();
   lado_primario();

   // translate([0,0,20]) rotate([180,0,0]) caja_secundario();
   // -$t * ciclo_animacion * 360 / dp_lobulos
   // sec_tornillos_agarre();
   lado_secundario();   


   color("blue") separador_leva();
   color("blue") casquillo();
   color(ColorLeva) leva();
   translate([0,0,0]) aro_posicionador_tornillos_agarre();
   if (fabricar) translate([-13,15]) leva(); // una segunda leva para escoger la mejor
   if (!fabricar && ver_vitaminas) color(ColorEjePrimario) translate([0,0,-5]) cylinder(d=rodamiento_entrada[d], h=36.5);   
}



// $vpt=[-5,0,15]; $vpr=[175,0,90] - min(1,max(0,(tan(($t-.5)*2)*180/PI+1)/2)) * [170,0,0] ; $vpd=170;
else if ( 1 ) { // animación del conjunto, pero sin rotación
   $t=0;
   lado_primario();
   lado_secundario();
   color(ColorLeva) leva();
   color("blue") separador_leva();
   color(ColorEjePrimario) translate([0,0,-5]) cylinder(d=rodamiento_entrada[d], h=36.5);
*   color(ColorAroPosicionador) render() aro_posicionador_tornillos_agarre();
} 

//$vpt=[0,0,10]; $vpr=[60,0,0] - min($t,.5) * [120,0,0]; $vpd=170;
else if ( 0 ) { // animación sencilla
   color(ColorCajaPrimario) translate([0,0,1]) difference() { contorno_primario(); hueco_caja_primario(); }
   disco_primario_girando();
   translate([0,0,-8]) color(ColorLeva) scale([1.002,1.002,1]) leva(); // sobredimensiono la leva para evitar puntos feos
   if (!fabricar && ver_vitaminas) color(ColorEjePrimario) translate([0,0,-5]) cylinder(d=rodamiento_entrada[d]+.05, h=36.5);  // sobredimensiono el eje para evitar puntos feos
   translate([0,0,dp_grosor+ds_grosor+ds_holgura_disco]) rotate([180,0,0]) disco_secundario_girando();
   RotacionSecundario() translate([0,0,16]) render() rotate([180,0,0]) difference() { contorno_secundario(); translate([-(rodamiento_secundario[D]/2 + abrazo_del_rod_secundario), 0]) square(rodamiento_secundario[D] + 2*abrazo_del_rod_secundario); hueco_caja_secundario(); }
} 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module leva() {
   rotate(fabricar ? 0 : ciclo_animacion * -$t * 360)
   translate(fabricar ? [6,-8] : excentricidad * [-1, 0,0] + [0,0,pri_sujeta_roent_fuera+rodamiento_entrada[g]+pri_sujeta_roent_dentro + dp_holgura_disco])
   difference() {
      cylinder(d=ajustado("rodamiento_excentrico[d]"), h=dp_grosor + ds_grosor + ds_conector);
      translate([excentricidad, 0, -mp]) {
         cylinder(d=ajustado("rodamiento_entrada[d]"), h=dp_grosor + ds_grosor + ds_conector + 2*mp);
         // a un cilindro le quito otro tangente, y por la línea de tangencia no hay filamento
         // y cerca de la línea de tangencia el fileteador pone un cuerno de filamento que supone una irregularidad incómoda
         linear_extrude(dp_grosor + ds_grosor + ds_conector + 2*mp)         
            projection(true)
               rotate(-ajustado("arco_evitar_filo_en_leva")/2)
                  rotate_extrude(angle=ajustado("arco_evitar_filo_en_leva"))
                    square([rodamiento_entrada[d]/2 + 1, mp]);
      }
   }
}

module casquillo() { // es para separar los rodamientos de los 2 discos   
   translate(fabricar ? [6,-8] : excentricidad * [-cos(ciclo_animacion * $t * 360), sin(ciclo_animacion * $t * 360),0] + [0,0,pri_sujeta_roent_fuera+rodamiento_entrada[g]+pri_sujeta_roent_dentro+dp_holgura_disco + (dp_grosor-rodamiento_excentrico[g])/2 + rodamiento_excentrico[g]])
      rodamiento([rodamiento_excentrico[D]-2*dp_reborde_rod, ajustado("rodamiento_excentrico[D] rll"), (dp_grosor - rodamiento_excentrico[g])/2 + (ds_grosor - rodamiento_excentrico[g])/2 + ds_conector]  -  [.5, .4, $alto_de_capa]);   
}

module separador_leva() { // un casquillo para poner la leva en su sitio, y que no se salga
 translate(fabricar ? [-25-excentricidad,27] : [0,0,pri_sujeta_roent_fuera + rodamiento_entrada[g] ]) 
   rodamiento([pri_separador_leva_d, pri_separador_leva_d + pri_separador_leva_g * 2, pri_sujeta_roent_dentro + dp_holgura_disco]);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module lado_primario() {

   color(ColorRodamientos) render() if (!fabricar && ver_vitaminas) 
      difference() {
         union() {
            translate([0, 0, pri_sujeta_roent_fuera]) rodamiento(rodamiento_entrada);
            if (ver_abierto) 
               translate([0,0,pri_sujeta_roent_fuera+rodamiento_entrada[g]+pri_sujeta_roent_dentro+dp_holgura_disco + dp_grosor +dp_holgura_disco + pri_hueco_bajo_rosec]) 
                  rodamiento(rodamiento_secundario);
         }
         if (ver_abierto)
            translate([1,-40,-mp]) cube([50,80,35]);    
      }
   if (fabricar) 
      translate([0,29]) {
         translate([rodamiento_secundario[D]/2,0]) color(ColorCajaPrimario) caja_primario();
         translate([-27,0]) disco_primario_girando();
      }
   else {
      color(ColorCajaPrimario) render() difference() { caja_primario(); if (ver_abierto) translate([0,-40,-mp]) cube([50,80,30]); };   
      translate([0, 0, pri_sujeta_roent_fuera+rodamiento_entrada[g]+pri_sujeta_roent_dentro+dp_holgura_disco]) disco_primario_girando();
   }
}

module lado_secundario() {
   color(ColorRodamientos) render() if (!fabricar && ver_vitaminas) 
      difference() {
         union() {
            translate([0, 0, primario_alto - pri_hueco_sobre_rosec - pri_hueco_bajo_rosec - rodamiento_secundario[g] + secundario_alto - sec_sujeta_roent_fuera - rodamiento_entrada[g]]) 
               rodamiento(rodamiento_entrada);
            if (ver_abierto) 
               translate([0,0, primario_alto - pri_hueco_bajo_rosec - rodamiento_secundario[g]]) 
                  rodamiento(rodamiento_secundario);
         }
         if (ver_abierto)
            translate([1,-40,-mp]) cube([50,80,35]);
      }
      
   if (fabricar) {
      translate([-rodamiento_secundario[D]/2-abrazo_del_rod_secundario,-24]) caja_secundario();
      translate([27,-34]) disco_secundario_girando();
   }
   else 
      translate([0,0,primario_alto - pri_hueco_sobre_rosec - rodamiento_secundario[g] - pri_hueco_bajo_rosec + sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro + ds_holgura_disco + ds_grosor])
         rotate([180,0,0]) {
            render() difference() { caja_secundario(); if (ver_abierto) translate([0,-40,-mp]) cube([50,80,30]); };
            translate([0,0,sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro + ds_holgura_disco]) 
               disco_secundario_girando();
         }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module disco_primario_girando() {
   translate(excentricidad * [-cos(ciclo_animacion * $t * 360), sin(ciclo_animacion * $t * 360)])
      rotate(ciclo_animacion * $t * 360 / dp_lobulos) {
         if (!fabricar && ver_vitaminas)
            translate([0,0,(dp_grosor - rodamiento_excentrico[g])/2])
               rodamiento(rodamiento_excentrico, color="#333333");
         color("#fabada")
            difference() {
               linear_extrude(dp_grosor, convexity=4)
                  difference() {
                     offset(-ajustado("dp_holgura_jaula")/2)
                        silueta_disco_primario();
                     circle(d=rodamiento_excentrico[D]-2*dp_reborde_rod);
                  }
               translate([0,0,(dp_grosor - rodamiento_excentrico[g])/2])
                  linear_extrude(dp_grosor) // sobra (dp_grosor - rodamiento_excentrico[g])/2 - mp) pero no me importa
                     circle(d=ajustado("rodamiento_excentrico[D]"));
               for (i = [0 : 120 : 359] )
                  rotate(i)
                     translate([tornillo_union_r, 0]) 
                        tornillo_cabeza_conica(ajustado("tornillo_union_cabeza"), ajustado("tornillo_union_pasa"), dp_grosor, embutido=ajustado("tornillo_union_entra")+mp);
            }
      }
}

module disco_secundario_girando() {
   translate(excentricidad * [-cos(ciclo_animacion * -$t * 360), sin(ciclo_animacion * -$t * 360)])
      rotate(-$t * ciclo_animacion * 360 / dp_lobulos) {
         if (!fabricar && ver_vitaminas)
            translate([0,0,(ds_grosor - rodamiento_excentrico[g])/2])
               rodamiento(rodamiento_excentrico, color="#333333");
         color("DodgerBlue")
            render()         
               difference() {
                  linear_extrude(ds_grosor + ds_conector)
                     difference() {
                        offset(-ajustado("ds_holgura_jaula")/2)                        
                           silueta_disco_secundario();
                        circle(d=rodamiento_excentrico[D]-2*ds_reborde_rod);                     
                        for (i = [0:120:359] )
                           rotate(i)
                              translate([tornillo_union_r, 0])
                                 circle(d=ajustado("tornillo_union_rosca"));
                     }
                  // hueco para el rodamiento
                  translate([0,0,(dp_grosor - rodamiento_excentrico[g])/2])
                     linear_extrude(dp_grosor) // sobra (dp_grosor - rodamiento_excentrico[g])/2 - mp) pero no me importa
                        circle(d=ajustado("rodamiento_excentrico[D]"));
                  // un rebaje en el aro que une los discos primario y secundario, para que los lóbulos del secundario no puedan llegar
                  // a tocar los rodillos del primario
                  translate([0,0,ds_grosor])
                     linear_extrude(ds_conector +mp, convexity=2)
                        difference() {
                           un_poquito_mas = 1;
                           circle(d=ds_diametro);
                           circle(d=dp_diametro - dp_rodillos - 2 * excentricidad - un_poquito_mas);
                        }
               }
      }
}               

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// caja primaria: es como un vaso con un agujero en el lado de entrada para el eje, un alojamiento para el rodamiento del eje
//    una jaula en la que rueda el disco primario, y un alojamiento en el lado de salida para un rodamiento_secundario


module pri_posiciones_agarre_rodamiento() {
   for ( i=[0:360/pri_aga_rod_sec_n:359])
      rotate(i)
         translate([(rodamiento_secundario[D] + pri_aga_rod_sec_d)/2,0])
            children();
}

module pri_tornillos_agarre(ver=true) {
   translate([0,0,primario_alto - pri_aga_rod_sec_ch])
      pri_posiciones_agarre_rodamiento() {
         translate([0,0,- pri_aga_rod_sec_h])
            cylinder(d=pri_aga_rod_sec_d, h=pri_aga_rod_sec_h);
         cylinder(d=pri_aga_rod_sec_cd, h=pri_aga_rod_sec_ch);
      }
}

module caja_primario() {

   difference() {
      linear_extrude(primario_alto)
         contorno_primario();
      // ahora voy descontando cosas:
      // agujero de entrada del eje
      translate([0,0,-mp]) 
         linear_extrude(pri_sujeta_roent_fuera + 2*mp )
            circle(d=(rodamiento_entrada[d] + rodamiento_entrada[D]) / 2);
      // alojamiento para el rodamiento de entrada
      translate([0,0,pri_sujeta_roent_fuera]) 
         linear_extrude(rodamiento_entrada[g] + pri_sujeta_roent_dentro + mp)
            circle(d=ajustado("rodamiento_entrada[D]"));
      // el hueco en el que se mueve el disco cicloidal
      translate([0,0,pri_sujeta_roent_fuera + rodamiento_entrada[g] + pri_sujeta_roent_dentro])
         linear_extrude(dp_holgura_disco + dp_grosor + dp_holgura_disco + mp)
            offset(ajustado("dp_holgura_jaula")/2)
               hueco_caja_primario();
      // alojamiento para el rodamiento del secundario
      translate([0,0,pri_sujeta_roent_fuera + rodamiento_entrada[g] + pri_sujeta_roent_dentro + dp_holgura_disco + dp_grosor + dp_holgura_disco + pri_hueco_bajo_rosec])
         linear_extrude(rodamiento_secundario[g] + pri_hueco_sobre_rosec + pri_hueco_bajo_rosec + mp)
            circle(d=ajustado("rodamiento_secundario[D]"));
      // un rebaje para que los tornillos que se agarran al anillo interno del rodamiento secundario no rocen
      translate([0,0,pri_sujeta_roent_fuera + rodamiento_entrada[g] + pri_sujeta_roent_dentro + dp_holgura_disco + dp_grosor + dp_holgura_disco - $alto_de_capa])
         linear_extrude($alto_de_capa + pri_hueco_bajo_rosec + mp)
            circle(d=pri_apoyo_rosec);
      // agujeros pasantes para tornillos M3 que sujeten el rodamiento y se fijen a tuercas que van metidas desde abajo      
      pri_posiciones_agarre_rodamiento() {         
         cylinder(d=ajustado("pri_aga_rod_sec_d"), h=primario_alto);
         translate([-(pri_aga_rod_sec_d/2+mp),-pri_aga_rod_sec_recorte/2, primario_alto - pri_hueco_sobre_rosec - rodamiento_secundario[g]]) 
            cube([pri_aga_rod_sec_d/2+mp,pri_aga_rod_sec_recorte, rodamiento_secundario[g]+mp]);
      }      
      // tuercas para esos tornillos, orientadas tangencialmente
      translate([0,0,-mp])          
         pri_posiciones_agarre_rodamiento() 
            rotate(30)
               cylinder(d=ajustado("pri_aga_rod_sec_td"), h=primario_alto - pri_aga_rod_sec_h - pri_aga_rod_sec_ch + pri_aga_rod_sec_th +mp, $fn=6);
      // cabezas de los tornillos
      translate([0,0, primario_alto - pri_hueco_sobre_rosec])
         pri_posiciones_agarre_rodamiento()
            cylinder(d=ajustado("pri_aga_rod_sec_cd"), h=pri_aga_rod_sec_ch+mp);
   }
   if (fabricar)
      pri_posiciones_agarre_rodamiento()
         rotate(30)
            rodamiento([ajustado("pri_aga_rod_sec_d")+.3, ajustado("pri_aga_rod_sec_td")-1.5, primario_alto - pri_aga_rod_sec_h - pri_aga_rod_sec_ch + pri_aga_rod_sec_th - $alto_de_capa], $fn=6);
      
}


module sec_posiciones_agarre_rodamiento() {
   for ( i=[0:360/((ds_lobulos+1)/2):359])
      rotate(i)
         translate([(rodamiento_secundario[d]-sec_aga_rod_sec_d)/2+sec_aga_rod_sec_rebaje,0])
            children();
}

module sec_tornillos_agarre(ver=true) {   
   translate(ver?[0,0,primario_alto - pri_hueco_sobre_rosec - pri_hueco_bajo_rosec + sec_sujeta_roent_fuera + sec_sujeta_roent_dentro + ds_holgura_disco + ds_grosor ]:[0,0,0])
      rotate(ver?[180,0,0]:[0,0,0])
         sec_posiciones_agarre_rodamiento() {
            cylinder(d=sec_aga_rod_sec_d, h=secundario_alto - pri_aga_rod_sec_ch);
            translate([0,0,secundario_alto - pri_hueco_bajo_rosec])
               cylinder(d=pri_aga_rod_sec_cd, h=pri_aga_rod_sec_ch);
         }
}      
   
module aro_posicionador_tornillos_agarre() {
   translate(fabricar?[27,-32]:[0,0,primario_alto - pri_hueco_sobre_rosec - rodamiento_secundario[g] - pri_hueco_bajo_rosec])
      difference() {
         // aquí no uso las medidas ajustadas porque esto va un poco a bulto
         rodamiento([aro_posidionador_tornillos_d, aro_posidionador_tornillos_D, pri_hueco_bajo_rosec]);
         translate([0,0,-mp])
            sec_posiciones_agarre_rodamiento()            
               cylinder(d=ajustado("sec_aga_rod_sec_cd") -.1, h=pri_aga_rod_sec_ch+2*mp); // fuerzo para que quede pequeño, para ajustar con lima (en este rebaje van pegadas las cabezas de los tornillos)
      }
}

module caja_secundario() {

   difference() {
      linear_extrude(secundario_alto)
         contorno_secundario();
      // ahora voy descontando cosas:
      // agujero de entrada del eje, o rebaje para que el rotor del rodamiento no roce
      if (eje_visto_por_secundario)
         translate([0,0,-mp]) 
            linear_extrude(sec_sujeta_roent_fuera + 2*mp )
               circle(d=(rodamiento_entrada[d] + rodamiento_entrada[D]) / 2);
      else
         translate([0,0,sec_sujeta_roent_fuera - $alto_de_capa])
            linear_extrude($alto_de_capa + mp)
               circle(d =(rodamiento_entrada[d] + rodamiento_entrada[D])/2);
      // alojamiento para el rodamiento de entrada
      translate([0,0,sec_sujeta_roent_fuera]) 
         linear_extrude(rodamiento_entrada[g] + sec_sujeta_roent_dentro + mp)         
            circle(d=ajustado("rodamiento_entrada[D]"));
      // el hueco en el que se mueve el disco cicloidal
      translate([0,0,sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro])
         linear_extrude(ds_holgura_disco + ds_grosor + ds_holgura_disco + mp)
            offset(ajustado("ds_holgura_jaula")/2)
               hueco_caja_secundario();               
      // alojamiento para el rodamiento del secundario      
      translate([0,0,secundario_alto - pri_hueco_bajo_rosec - rodamiento_secundario[g]])
         rodamiento([ajustado("rodamiento_secundario[d]"), rodamiento_secundario[D]+2*(abrazo_del_rod_secundario+mp), rodamiento_secundario[g]+0*pri_hueco_sobre_rosec + pri_hueco_bajo_rosec + separacion_entre_mitades + mp]);
      // hueco para los tornillos que agarran el rodamiento al primario (en realidad lo que hago es crear un asiento al rodamiento)
      translate([0,0,secundario_alto - pri_hueco_sobre_rosec - pri_hueco_bajo_rosec - rodamiento_secundario[g] - separacion_entre_mitades])
         rodamiento([sec_apoyo_rosec, rodamiento_secundario[D]+2*(abrazo_del_rod_secundario+mp), pri_hueco_sobre_rosec + separacion_entre_mitades + mp]);
      
      
      // hueco para el anillo de posicionado de tornillos de agarre al rodamiento
      translate([0,0,secundario_alto - pri_aga_rod_sec_ch])
         rodamiento([ajustado("aro_posidionador_tornillos_d"), rodamiento_secundario[d]+mp, pri_aga_rod_sec_ch + mp]);

         
      // tornillos que agarran la caja al rodamiento secundario
      sec_posiciones_agarre_rodamiento() {
         translate([0,0,mp]) // huecos pasantes para los tornillos
            cylinder(d=ajustado("sec_aga_rod_sec_d"), h=secundario_alto);
         translate([0,0,-mp]) // rebajes para las tuercas que tiran de los tornillos que agarran el rodamiento secundario
            cylinder(d=ajustado("sec_aga_rod_sec_td"), h=sec_aga_rod_sec_th + mp);
         translate([0,0,secundario_alto - pri_hueco_bajo_rosec]) // para las cabezas de los tornillos
            cylinder(d=ajustado("sec_aga_rod_sec_cd"), h=pri_hueco_bajo_rosec + mp);
         if (fabricar) // unas incisiones que aseguren que el churrito de arriba apoya bien sobre el soporte que haré luego
            for (i=[0 : 360/sec_aga_rod_sec_incisiones: 359 ]) 
               rotate(i)
                  translate([0, -mp/2, sec_aga_rod_sec_th-mp]) 
                     cube([ajustado("sec_aga_rod_sec_td")/2-mp, mp, $alto_de_capa + mp]);
         }

      // hacer hueco para las rebabas resultantes de pegar al aro-guía los tornillos que sujetan el secundario al rodamiento
      // se puede evitar este recorte si se recorta la rebaba de pegamento, pero entonces el tornillo queda prácticamente suelto
      difference() {         
         sec_posiciones_agarre_rodamiento()
            translate([0,0,secundario_alto - pri_hueco_bajo_rosec])
               resize([9,12]) cylinder(d=sec_aga_rod_sec_td, h=pri_hueco_bajo_rosec + mp);
         translate([0,0,secundario_alto - pri_hueco_bajo_rosec])
            linear_extrude(pri_hueco_bajo_rosec + mp)
               offset(ajustado("ds_holgura_jaula")/2 + ancho_churrito)
                  hueco_caja_secundario();               
      }         

      // alojamiento para tuercas en las que atornillar algo al secundario
      for (i = [0 : 360/sal_cuantos : 359])
         rotate(i + 360/(ds_lobulos+1)/2)
            translate([sal_radio, 0]) {
               translate([0,0,-mp])
                  linear_extrude(sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro + 2*mp)
                     circle(d=ajustado("sal_tornillo"));
               translate([0,0,sec_sujeta_roent_fuera + rodamiento_entrada[g] + sec_sujeta_roent_dentro - sal_tuerca_h])
                  linear_extrude(sal_tuerca_h + mp)
                     rotate(30)
                        circle(d=ajustado("sal_tuerca_d"), $fn=6);
            }
   }   

   // soportes de los huecos de las tuercas
   if (fabricar)
      sec_posiciones_agarre_rodamiento()
         // el agujero interior quiero que ajuste mucho a un M3, porque así atornillo y tiro con una torsión brusca
         rodamiento([ajustado("sec_aga_rod_sec_d") -.2, ajustado("sec_aga_rod_sec_d")+sec_aga_rod_sec_gro_soporte*2, sec_aga_rod_sec_th-$alto_de_capa]);
}

// silueta externa del contenedor del lado primario
module contorno_primario() {   
   circle(d=rodamiento_secundario[D] + 2*abrazo_del_rod_secundario);
}
module contorno_secundario() { contorno_primario(); }

module hueco_caja_primario() {   
   if ($coger_hecho)
      projection(true) import(Nombre_stl_pri("jaula"));
   else
      for ( i = [0:1/$calidad:1] )
         translate(excentricidad * [-cos(i * 360), sin(i * 360)])
            rotate(i * 360 / dp_lobulos)
               silueta_disco_primario($coger_hecho=1);   
}

module exporta_hueco_caja_primario() {
   render()
      translate([0,0,-.5]) 
         linear_extrude(1)
            hueco_caja_primario($coger_hecho=0, $calidad=720, $fs=.1, $fa=.1);
   echo(str("->    ", Nombre_stl_pri("jaula"), "    <-"));
   echo("->    RECUERDA LIMPIAR CON { LimDis .5; RemDou .05; ^T }");
}   


module hueco_caja_secundario() {   
   if ($coger_hecho) 
      projection(true) import(Nombre_stl_sec("jaula"));
   else 
      for ( i = [0:1/$calidad:1] )
         translate(excentricidad * [-cos(i * 360), sin(i * 360)])
            rotate(i * 360 / ds_lobulos)
               silueta_disco_secundario($coger_hecho=1);   
}

module exporta_hueco_caja_secundario() {
   render()
      translate([0,0,-.5]) 
         linear_extrude(1)
            hueco_caja_secundario($coger_hecho=0, $calidad=720, $fs=.1, $fa=.1);
   echo(str("->    ", Nombre_stl_sec("jaula"), "    <-"));
   echo("->    RECUERDA LIMPIAR CON { LimDis .5; RemDou .05; ^T }");
}   


///////////////////////////////////////////////////////////////////////////////////////////////////

// silueta 2D del disco cicloidal primario (sin holgura)
module silueta_disco_primario() {
   if ($coger_hecho) 
      projection(true) import(Nombre_stl_pri("disco"));
   else 
      disco_cicloide(dp_lobulos, dp_diametro, excentricidad, dp_rodillos);
}


module exporta_disco_primario() {   
   render()
      translate([0,0,-.5]) 
         linear_extrude(1)
            silueta_disco_primario($coger_hecho=0, $calidad=720, $fs=.1, $fa=.1);
   echo(str("->    ", Nombre_stl_pri("disco"), "    <-"));
   echo("->    RECUERDA LIMPIAR CON { LimDis .5; RemDou .05; ^T }");
}

// silueta 2D del disco cicloidal secundario (sin holgura)
module silueta_disco_secundario() {
   if ($coger_hecho)
      projection(true) import(Nombre_stl_sec("disco"));
   else // "disco(9,34,2,6)'.stl" se ha generado haciendo una limpieza con blender de lo que genera un translate([0,0,-.5]) linear_extrude(1) aplicado a la siguiente línea
      disco_cicloide(ds_lobulos, ds_diametro, excentricidad, ds_rodillos);
}

module exporta_disco_secundario() {   
   render()
      translate([0,0,-.5]) 
         linear_extrude(1)
            silueta_disco_secundario($coger_hecho=0, $calidad=720, $fs=.1, $fa=.1);
   echo(str("->    ", Nombre_stl_sec("disco"), "    <-"));
   echo("->    RECUERDA LIMPIAR CON { LimDis .5; RemDou .05; ^T }");
}


module disco_cicloide(lobulos, diametro, excentricidad, rodillos, holgura=0) {
   difference() {
      epsilon = 1e-4;
      circle(d=diametro + rodillos);
      for ( i = [0 : 1/$calidad : 1-epsilon ] ) 
         rotate(i*360/lobulos)
            translate(excentricidad * [cos(i*360), sin(i*360)])
               for ( paso=[0 : 360/(lobulos+1) : 360-epsilon ] )
                  rotate(paso)
                     translate([diametro/2, 0])
                        circle(d=rodillos + 2*holgura);
   }   
}

module tornillo_cabeza_conica(dc, dt=0, largo=0, embutido=0) {
  epsilon=0.01;
   translate([0,0,embutido]) {
      translate([0,0,-embutido-epsilon])
         cylinder(d=dc, h=embutido + epsilon);
      translate([0,0,-epsilon])
         cylinder(d1=dc + 2*epsilon, d2=0, h=(dc + epsilon)/2);
      if (dt>0 && largo>0)
         cylinder(d=dt, h=largo);
   }
}