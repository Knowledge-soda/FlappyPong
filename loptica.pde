class Loptica {
    float X,Y;
    int Velicina;
    int Boja;
    float BrzinaVert;
    float BrzinaHorizon;

    Loptica(float x,float y) {
        X = x;
        Y = y;
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
        BrzinaVert += gravitacija;
        BrzinaVert -= (BrzinaVert * otporZraka) * abs(BrzinaVert);
        Y += BrzinaVert;
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

    void OdbijOdReketa() {
        // ako se loptica nalazi unutar širine reketa
        if ((X + Velicina/2 > reket_x - reketSirina/2) && (X - Velicina/2 < reket_x + reketSirina/2)) {
          // ako je udaljenost središta loptice i središta reketa manja od pola veličine loptice i pomaka miša
          // tj. ako je došlo do sudara loptice i reketa
          if (dist(X, Y, X, reket_y) <= Velicina/2 + abs(reket_dy)) {
              OdbijOdDna(reket_y);
              // povećaj brzinu i položaj loptice u odnosu na jačinu udara
              if (reket_dy < 0) {
                Y += reket_dy;
                BrzinaVert += reket_dy;
              }
              //ide li loptica lijevo ili desno ovisi o točki reketa na koju je pala
              BrzinaHorizon = (X - reket_x)/10; // 1/10 vrijednosti najprirodnije
          }
        }
    }

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

    void OdbijOdDna2(float podloga) {
        // najdonju točku loptice postavi na dno podloge, promijeni smjer brzine (pomonoži s -1)
        // smanji brzinu za otpor podloge
        Y = podloga - Velicina/2;
        BrzinaVert -= (BrzinaVert * otporPodlogeVert);
        BrzinaVert *= -0.5;
    }
}
