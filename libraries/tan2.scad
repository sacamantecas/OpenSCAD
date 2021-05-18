/*
    planteamiento: trazar una línea tangente a un círculo de radio r centrado
    en el origen, que pase por un punto de coordenadas conocidas
*/

// tangente por un lado del círculo
function alfa(R,P,Q)= sign(Q) 
    * acos((P*sqrt(pow(P,2)+pow(Q,2)-pow(R,2))-R*Q)/(pow(P,2)+pow(Q,2)));
    
// y por el otro lado    
function beta(R,P,Q)= 90-sign(P)
    * acos((Q*sqrt(pow(P,2)+pow(Q,2)-pow(R,2))-R*P)/(pow(P,2)+pow(Q,2)));

r=10;
p=10;
q=15;
ancho=5;
alto=3;

// hull() actúa sobre un polígono, pero las funciones alfa() y beta()
// calculan a partir de un círculo. 
// La diferencia se ve haciendo el círculo con $fn=4 por ejemplo
hull() {
#    circle(r); 
#    translate([p, q])
        square([ancho, alto], center=true);
}

// escoger las esquinas según el cuadrante donde esté el rectánculo
color("red") // esquina inferior derecha 
    translate([p+ancho/2, q-alto/2]) 
        rotate([0, 0, alfa(r, p+ancho/2, q-alto/2)]) 
            square([100, .1], center=true);

color("blue") // esquina superior izquierda
    translate([p-ancho/2, q+alto/2]) 
        rotate([0, 0 , beta(r, p-ancho/2, q+alto/2)]) 
            square([100, .1], center=true);

