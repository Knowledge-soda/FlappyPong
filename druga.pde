class Igra2{
    int startVrijeme;
    Loptica loptica1, loptica2;
    Reket reket;
    ArrayList<int[]> ciglice;
    int tip;

    //***KONSTANTE***
    int ciglaSirina = 50, ciglaDuzina = 20;

    Igra2(int tip){
        this.tip = tip; // tip = 2 za drugu igru, 3 za trecu
        loptica1 = new Loptica(100, 400);
        if (tip == 2){
            zaslon = 4;
            reket = new Reket(50, 500);
        }
        if (tip == 3){
            zaslon = 5;
            reket = new Reket(50, height - 20);
            loptica2 = new Loptica(100, 400);
        }
        ciglice = new ArrayList<int[]>();
        OdrediCiglice();
        startVrijeme = millis();
    }
    void Igraj(){
        float dx = mouseX - width / 2;
        float dy = 0;
        if (tip == 2){ // u trecoj igri ignoriramo vertikalno pomicanje misa
            dy = mouseY - height / 2;
        }
        reket.Pomakni(dx, dy);
        GLWindow r = (GLWindow)surface.getNative();
        r.warpPointer(width / 2, height / 2);

        background(255);
        IspisiVrijeme(startVrijeme);
        NacrtajCiglice();
        loptica1.Nacrtaj();
        if (tip == 3)
            loptica2.Nacrtaj();
        reket.Nacrtaj();
        loptica1.PrimijeniGravitaciju();
        loptica1.ZadrziNaZaslonu();
        loptica1.OdbijOdReketa(reket);
        loptica1.PrimijeniHorizontalnuBrzinu();
        SudaranjeSaCiglicama(loptica1);
        if (tip == 3){ // samo u trecoj igri postoji druga loptica
            loptica2.PrimijeniGravitaciju();
            loptica2.ZadrziNaZaslonu();
            loptica2.OdbijOdReketa(reket);
            loptica2.PrimijeniHorizontalnuBrzinu();
            SudaranjeSaCiglicama(loptica2);
        }
        // kraj igre
        if( ciglice.size() == 0 ){
            krajVrijeme = millis();
            ukupnoVrijemeSec = (krajVrijeme - startVrijeme)/1000;
            // ukupnom rezultatu dodajemo broj obrnuto proporacionalan vremenu potrebnom za pogađanje svih ciglica
            rezultat += round(150 - 2 * ukupnoVrijemeSec);
            //****************
            if (tip == 2){
                // zaslon = 5;
                igra3 = new Igra2(3);
            } else {
                zaslon = 2;
            }
        }
    }

    void OdrediCiglice(){
        // ciglice ćemo pamtiti u listu
        // sve će biti iste širine (50) i dužine (10)
        for(int i = 0; i < 12; i++)
            for(int j = 0; j < 10; j++){
                // prvi clan niza je pocetak cigle x koordinata, zatim pocetak cigle
                // y koordinata, i boja koju ćemo random odabrati izmedu njih 5
                // boje: 0 - crvena, 1 - žuta, 2 - plava, 3 - zelena, 4 - narančasta
                int boja = round(random(0,4));
                int[] novaCiglica = {i*50, j*20 + 50, boja};
                ciglice.add(novaCiglica);
            }
    }
    void NacrtajCiglice(){
        rectMode(CORNER);
        stroke(0);
        for(int i = 0; i < ciglice.size(); i++){
            // boje: 0 - crvena, 1 - žuta, 2 - plava, 3 - zelena, 4 - narančasta
            int[] ciglica = ciglice.get(i);
            if(ciglica[2] == 0) fill(255,0,0);
            else if(ciglica[2] == 1) fill(255,255,0);
            else if(ciglica[2] == 2) fill(30,144,255);
            else if(ciglica[2] == 3) fill(50,205,50);
            else fill(255,140,0);
            rect(ciglica[0], ciglica[1], ciglaSirina, ciglaDuzina);
        }
    }

    void SudaranjeSaCiglicama(Loptica l) {
        float pLijevi = l.pX - l.Velicina / 2;
        float pGornji = l.pY - l.Velicina / 2;
        float pDesni  = l.pX + l.Velicina / 2;
        float pDonji  = l.pY + l.Velicina / 2;
        float Lijevi = l.X - l.Velicina / 2;
        float Gornji = l.Y - l.Velicina / 2;
        float Desni  = l.X + l.Velicina / 2;
        float Donji  = l.Y + l.Velicina / 2;
        if (l.BrzinaVert < 0){
            for(int i = ciglice.size() - 1; i >= 0; i-- ){
                int[] ciglica = ciglice.get(i);
                float cLijevi = ciglica[0];
                float cGornji = ciglica[1];
                float cDesni  = ciglica[0] + ciglaSirina;
                float cDonji  = ciglica[1] + ciglaDuzina;
                // ako se sudari s ciglicom
                float udarac_x = HorizontalCollide(
                    pLijevi, pGornji, Lijevi, Gornji, cDonji, cLijevi, cDesni);
                float udarac_x2 = HorizontalCollide(
                    pDesni, pGornji, Desni, Gornji, cDonji, cLijevi, cDesni);
                if ((!Float.isNaN(udarac_x)) || !(Float.isNaN(udarac_x2))) {
                    //OdbijOdStropa(ciglica[1]);
                    l.BrzinaVert -= (l.BrzinaVert * otporPodlogeVert);
                    l.BrzinaVert *= -1;
                    ciglice.remove(i);
                    break;
                }
            }
        }
        if (l.BrzinaVert > 0){
            for(int i = ciglice.size() - 1; i >= 0; i-- ){
                int[] ciglica = ciglice.get(i);
                float cLijevi = ciglica[0];
                float cGornji = ciglica[1];
                float cDesni  = ciglica[0] + ciglaSirina;
                float cDonji  = ciglica[1] + ciglaDuzina;
                // ako se sudari s ciglicom
                float udarac_x = HorizontalCollide(
                    pLijevi, pDonji, Lijevi, Donji, cGornji, cLijevi, cDesni);
                float udarac_x2 = HorizontalCollide(
                    pDesni, pDonji, Desni, Donji, cGornji, cLijevi, cDesni);
                if ((!Float.isNaN(udarac_x)) || !(Float.isNaN(udarac_x2))) {
                    //OdbijOdStropa(ciglica[1]);
                    l.BrzinaVert -= (l.BrzinaVert * otporPodlogeVert);
                    l.BrzinaVert *= -1;
                    ciglice.remove(i);
                    break;
                }
            }
        }
        if (l.BrzinaHorizon > 0){
            // loptica ide desno
            for(int i = ciglice.size() - 1; i >= 0; i-- ){
                int[] ciglica = ciglice.get(i);
                float cLijevi = ciglica[0];
                float cGornji = ciglica[1];
                float cDesni  = ciglica[0] + ciglaSirina;
                float cDonji  = ciglica[1] + ciglaDuzina;
                // ako se sudari s ciglicom
                float udarac_y = VerticalCollide(
                    pDesni, pGornji, Desni, Gornji, cLijevi, cGornji, cDonji);
                float udarac_y2 = VerticalCollide(
                    pDesni, pDonji, Desni, Donji, cLijevi, cGornji, cDonji);
                if ((!Float.isNaN(udarac_y)) || !(Float.isNaN(udarac_y2))) {
                    //OdbijOdStropa(ciglica[1]);
                    l.BrzinaHorizon -= (l.BrzinaHorizon * otporPodlogeHoriz);
                    l.BrzinaHorizon *= -1;
                    ciglice.remove(i);
                    break;
                }
            }
        }
        if (l.BrzinaHorizon < 0){
            for(int i = ciglice.size() - 1; i >= 0; i-- ){
                int[] ciglica = ciglice.get(i);
                float cLijevi = ciglica[0];
                float cGornji = ciglica[1];
                float cDesni  = ciglica[0] + ciglaSirina;
                float cDonji  = ciglica[1] + ciglaDuzina;
                // ako se sudari s ciglicom
                float udarac_y = VerticalCollide(
                    pLijevi, pGornji, Lijevi, Gornji, cDesni, cGornji, cDonji);
                float udarac_y2 = VerticalCollide(
                    pLijevi, pDonji, Lijevi, Donji, cDesni, cGornji, cDonji);
                if ((!Float.isNaN(udarac_y)) || !(Float.isNaN(udarac_y2))) {
                    //OdbijOdStropa(ciglica[1]);
                    l.BrzinaHorizon -= (l.BrzinaHorizon * otporPodlogeHoriz);
                    l.BrzinaHorizon *= -1;
                    ciglice.remove(i);
                    break;
                }
            }
        }
    }
}
