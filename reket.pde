class Reket {
    float X, Y;
    float dX, dY; //pomak
    float Sirina, Visina;
    color Boja;

    Reket(float x, float y){
        X = x;
        Y = y;
        dX = 0;
        dY = 0;
        Boja = color(0);
        Sirina = 100;
        Visina = 10;
    }

    void Nacrtaj(){
        fill(Boja);
        rectMode(CENTER);
        rect(X, Y, Sirina, Visina);
    }

    void Pomakni(float dx, float dy){
        dX = dx;
        dY = dy;
        X += dX;
        Y += dY;
        X = min(max(-Sirina / 3, X), width + Sirina / 3);
        Y = min(max(-Visina / 3, Y), height + Visina / 3);
    }
}
