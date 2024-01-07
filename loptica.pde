float VerticalCollide(float x1, float y1, float x2, float y2, float xl, float ylu, float yld){
    if ((x1 < xl && x2 < xl) || (x1 > xl && x2 > xl)) return Float.NaN;
    float y_interp = map(xl, x1, x2, y1, y2);
    if (ylu < y_interp && y_interp < yld) return y_interp;
    return Float.NaN;
}

float HorizontalCollide(float x1, float y1, float x2, float y2, float yl, float xll, float xlr){
    if ((y1 < yl && y2 < yl) || (y1 > yl && y2 > yl)) return Float.NaN;
    float x_interp = map(yl, y1, y2, x1, x2);
    if (xll < x_interp && x_interp < xlr) return x_interp;
    return Float.NaN;
}

class Loptica {
    float X,Y;
    float pX, pY;
    int Velicina;
    int Boja;
    float BrzinaVert;
    float BrzinaHorizon;

    Loptica(float x,float y) {
        X = x;
        Y = y;
        pX = x;
        pY = y;
        Velicina = 20;
        Boja = color(77,0,75);
        BrzinaVert = 0;
        BrzinaHorizon = 0;
    }

    void Nacrtaj(){
        fill(Boja);
        ellipse(X, Y, Velicina, Velicina);
    }

    void PrimijeniGravitaciju() {
        // brzinu loptice povećava utjecaj gravitacije, a smanjuje otpor zraka
        // vertikalni položaj loptice mijenja se za brzinu loptice
        pY = Y;
        Y += BrzinaVert;
        BrzinaVert += gravitacija;
        BrzinaVert -= (BrzinaVert * otporZraka) * abs(BrzinaVert);
    }

    void OdbijOdDna(float podloga) {
        // najdonju točku loptice postavi na dno podloge, promijeni smjer brzine (pomonoži s -1)
        // smanji brzinu za otpor podloge
        Y = podloga - Velicina/2;
        BrzinaVert -= (BrzinaVert * otporPodlogeVert);
        BrzinaVert *= -1;
    }

    void OdbijOdStropa(float podloga) {
        Y = podloga + Velicina/2;
        BrzinaVert -= (BrzinaVert * otporPodlogeVert);
        BrzinaVert *= -1;
    }

    void PrimijeniHorizontalnuBrzinu(){
        pX = X;
        X += BrzinaHorizon;
        BrzinaHorizon -= (BrzinaHorizon * otporZraka) * abs(BrzinaHorizon);
    }

    void OdbijOdLijevogRuba(float podloga){
        X = podloga + Velicina/2;
        BrzinaHorizon -= (BrzinaHorizon * otporPodlogeHoriz);
        BrzinaHorizon *= -1;
    }

    void OdbijOdDesnogRuba(float podloga){
        X = podloga-(Velicina/2);
        BrzinaHorizon *= -1;
        BrzinaHorizon -= (BrzinaHorizon * otporPodlogeHoriz);
    }

    void ZadrziNaZaslonu() {
        // ako loptica padne na pod, tj. ako najdonja točka loptice bude veća od visine ekrana
        if (Y + Velicina/2 > height) {
          OdbijOdDna(height);
        }
        // ako loptica dotakne strop
        if (Y - Velicina/2 < 0) {
          OdbijOdStropa(0);
        }
        // ako loptica dotakne lijevi rub
        if (X - Velicina/2 < 0){
          OdbijOdLijevogRuba(0);
        }
        // ako loptica dotakne desni rub
        if (X + Velicina/2 > width){
          OdbijOdDesnogRuba(width);
        }
    }

    void OdbijOdReketa(Reket reket) {
        if (BrzinaVert < 0) return;
        float rLijevi = reket.X - reket.Sirina / 2;
        float rDesni = reket.X + reket.Sirina / 2;
        float rGornji = reket.Y - reket.Visina / 2;
        float rpLijevi = reket.X - reket.dX - reket.Sirina / 2;
        float rpDesni = reket.X - reket.dX + reket.Sirina / 2;
        float rpGornji = reket.Y - reket.dY - reket.Visina / 2;
        float pLijevi = pX - Velicina / 2;
        float pDesni  = pX + Velicina / 2;
        float pDonji  = pY + Velicina / 2;
        float Lijevi = X - Velicina / 2;
        float Desni  = X + Velicina / 2;
        float Donji  = Y + Velicina / 2;
        if (Desni < rLijevi || Lijevi > rDesni){
            return; // loptica izvan x-osi reketa
        }
        if (rGornji < Donji && Donji < rpGornji){ // reket je prosao kroz lopticu
            rGornji = (pDonji + Donji) / 2;
        }
        float x1 = HorizontalCollide(
            pLijevi, pDonji, Lijevi, Donji, rGornji, rLijevi, rDesni);
        float x2 = HorizontalCollide(
            pDesni, pDonji, Desni, Donji, rGornji, rLijevi, rDesni);
        float x3 = HorizontalCollide(
            pLijevi, pDonji, Lijevi, Donji, rpGornji, rpLijevi, rpDesni);
        float x4 = HorizontalCollide(
            pDesni, pDonji, Desni, Donji, rpGornji, rpLijevi, rpDesni);
        if (Float.isNaN(x1) && Float.isNaN(x2) && Float.isNaN(x3) && Float.isNaN(x4)) return;
        if (Float.isNaN(x1) && Float.isNaN(x2)){
            x1 = x3;
            x2 = x4;
        }
        float x = 0;
        if (Float.isNaN(x1)) x = x2 - Velicina / 2;
        else x = x1 + Velicina / 2;
        float Kut = -map(x, rLijevi, rDesni, -PI/12, PI/12);

        float nBrzinaHorizon = BrzinaHorizon * cos(Kut) - BrzinaVert * sin(Kut);
        float nBrzinaVert = BrzinaHorizon * sin(Kut) - BrzinaVert * cos(Kut);
        BrzinaVert = nBrzinaVert;
        BrzinaHorizon = nBrzinaHorizon;
        if (BrzinaVert > -4){
            BrzinaVert = -10;
        }
        BrzinaVert += reket.dY * 1.5;
        BrzinaVert -= (BrzinaVert * otporPodlogeVert);
        // if (BrzinaVert > -1) BrzinaVert = -3;
        Y = reket.Y - reket.Visina / 2 - Velicina / 2 + BrzinaVert;
        /*
        // ako se loptica nalazi unutar širine reketa
        if ((X + Velicina/2 > reket.X - reket.Sirina/2) && (X - Velicina/2 < reket.X + reket.Sirina/2)) {
          // ako je udaljenost središta loptice i središta reketa manja od pola veličine loptice i pomaka miša
          // tj. ako je došlo do sudara loptice i reketa
          if (dist(X, Y, X, reket.Y) <= Velicina/2 + abs(reket.dY)) {
              OdbijOdDna(reket.Y);
              // povećaj brzinu i položaj loptice u odnosu na jačinu udara
              if (reket.dY < 0) {
                Y += reket.dY;
                BrzinaVert += reket.dY;
              }
              //ide li loptica lijevo ili desno ovisi o točki reketa na koju je pala
              BrzinaHorizon = (X - reket.X)/10; // 1/10 vrijednosti najprirodnije
          }
        }
        */
    }

    /*
    void OdbijOdReketa2() {
        // ako se loptica nalazi unutar širine reketa
        if ((X + Velicina/2 > reket_x - reketSirina/2) && (X - Velicina/2 < reket_x + reketSirina/2)) {
          // ako je udaljenost središta loptice i središta reketa manja od pola veličine loptice i pomaka miša
          // tj. ako je došlo do sudara loptice i reketa
          if (dist(X, Y, X, height - 50) <= Velicina/2 + abs(reket_dx)) {
              OdbijOdDna2(height - 20);
              // povećaj brzinu i položaj loptice u odnosu na jačinu udara
              if (reket_dx < 0) {
                X += (X - reket_x)/10;
                BrzinaVert += reket_dx;
              }
              //ide li loptica lijevo ili desno ovisi o točki reketa na koju je pala
              BrzinaHorizon = reket_dx;// 1/10 vrijednosti najprirodnije
          }
        }
    }
    */

    void OdbijOdDna2(float podloga) {
        // najdonju točku loptice postavi na dno podloge, promijeni smjer brzine (pomonoži s -1)
        // smanji brzinu za otpor podloge
        Y = podloga - Velicina/2;
        BrzinaVert -= (BrzinaVert * otporPodlogeVert);
        BrzinaVert *= -0.5;
    }
}
