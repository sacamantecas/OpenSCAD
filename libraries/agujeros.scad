// base de datos de agujeros
// argumento de entrada: radio del agujero que quieres
// devuelve el radio que debes pedir, extrapolando a partir de la experiencia acumulada en un array de pares [obtenido, solicitado]
//
//  ¡¡ VALORES EXPRESADOS EN DIAMETRO !!
//   
function agujero(radio) = lookup(radio,
   // la siguiente línea es un array que saco de mi base de datos de agujeros
   [[0,0.5],[1.6,2.9],[2.6,3],[2.7,3],[2.9,3.1],[3.1,3.4],[3.4,3.6],[3.6,4],[4.6,5],[5.6,6],[6.6,7],[7.7,8],[8.7,9],[9.5,10],[10.7,11],[11.6,12],[12.7,13],[13.6,14],[14.1,14.4],[14.7,15],[14.8,15.3],[15.3,15.4],[15.8,16],[16,16.2],[16.8,17],[16.9,17.2],[17.1,17.3],[17.8,18],[18.7,19],[19.7,22],[20.7,21],[21.6,22],[22.7,23],[23.6,24],[24.7,25],[25.6,35.8],[25.7,26],[26.7,27],[27.7,28],[28.9,29],[29.7,30],[50.1,50.1],[50.2,50.3],[99999.9,99999.9]]		
   ) ;
