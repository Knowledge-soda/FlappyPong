class Igra1 {
    Loptica loptica;
    Reket reket;

    ArrayList<int[]> zidovi;
    float zadnjeVrijemeDodavanja = 0;

    int zivot = 100;
    int rezultat = 0;

    //***KONSTANTE***
    //zidovi info
    int BrzinaZidova = 5;
    int intervalDodavanjaZidova = 1000;
    int minUdaljenostZidova = 200;
    int maxUdaljenostZidova = 300;
    int sirinaZida = 80;
    color bojaZidova = color(0,128,0);

    // zivot i rezultat info
    int maxZivot = 100;
    int sirinaLinijeZivota = 60;

    Igra1(){
        zaslon = 1;

        reket = new Reket(90, 350);
        loptica = new Loptica(100, 300);
        zidovi = new ArrayList<int[]>();
        zadnjeVrijemeDodavanja = 0;
        zivot = 100;
        rezultat = 0;
    }

    void Igraj(){
        float dx = mouseX - width / 2;
        float dy = mouseY - height / 2;
        reket.Pomakni(dx, dy);
        GLWindow r = (GLWindow)surface.getNative();
        r.warpPointer(width / 2, height / 2);

        if (pjesmica != null){
            pjesmica.play();
        }
        background(110,193,248);

        loptica.Nacrtaj();
        reket.Nacrtaj();
        loptica.PrimijeniGravitaciju();
        loptica.ZadrziNaZaslonu();
        loptica.PrimijeniHorizontalnuBrzinu();
        loptica.OdbijOdReketa(reket);

        DodavanjeZidova();
        for (int i = 0; i < zidovi.size(); i++) {
            IzbrisiZid(i);
            PomakniZid(i);
            CrtajZid(i);
            SudaranjeSaZidom(i,loptica);
        }
        IscrtajLinijuZivota(loptica);
        ispisiRezultat();

        /*
        // inicijaliziraj varijable na pocetno
        PrintTop5 = 1;
        trazeni = 5;
        korisnikIme = "";
        */
    }

    void DodavanjeZidova() {
        // ako je između sada i vremena zadnjeg dodavanja zida prošlo više od zadanog intervala
        if (millis() - zadnjeVrijemeDodavanja > intervalDodavanjaZidova) {
            // udaljenost između novog para zidova bude random vrijednost unutar zadanog intervala
            int udaljenostZidova = round(random(minUdaljenostZidova, maxUdaljenostZidova));
            // visina gornjeg zida bude također random vrijednost
            int visinaGornjegZida = round(random(0, height-udaljenostZidova));
            // zid pamtimo kao niz u kojem su vrijednosti
            // {početnaTočkaZida, visinaGornjegZida, širinaZida, udaljenostZidova, brojSudaraLopticeSaZidom};
            int[] noviParZidova = {width, visinaGornjegZida, sirinaZida, udaljenostZidova, 0};
            zidovi.add(noviParZidova);
            zadnjeVrijemeDodavanja = millis();
        }
    }

    void CrtajZid(int index) {
        int[] zid = zidovi.get(index);
        // zid pamtimo kao niz u kojem su vrijednosti
        // {početnaTočkaZida, visinaGornjegZida, širinaZida, udaljenostZidova, brojSudaraLopticeSaZidom};
        rectMode(CORNER);
        fill(bojaZidova);
        // gornji zid: od (početnaTočka, 0) do (širinaZida, visinaGornjegZida)
        rect(zid[0], 0, zid[2], zid[1], 7);
        //donji zid: od (početnaTočka, visinaGornjegZida + udaljenostZidova) do (širinaZida, preostala visina))
        rect(zid[0], zid[1]+zid[3], zid[2], height-(zid[1]+zid[3]), 7);
    }
    void PomakniZid(int index) {
        int[] zid = zidovi.get(index);
        // zidove mičemo ulijevo
        zid[0] -= BrzinaZidova;
    }

    void IzbrisiZid(int index) {
        int[] zid = zidovi.get(index);
        // ako je početnaTočka - širinaZida < 0, odnosno zid ispada sa zaslona
        if (zid[0]+zid[2] <= 0) {
            zidovi.remove(index);
        }
    }

    void SudaranjeSaZidom(int index,Loptica l) {
        int[] zid = zidovi.get(index);
        int sudar = zid[4];
        int gornjiZidX = zid[0];
        int gornjiZidY = 0;
        int gornjiZidVisina = zid[1];
        int donjiZidX = zid[0];
        int donjiZidY = zid[1] + zid[3];
        int donjiZidVisina = height - ( zid[1] + zid[3] );

        // ako se sudari s gornjim zidom
        if ((l.X + l.Velicina/2 > gornjiZidX) &&
            (l.X - l.Velicina/2 < gornjiZidX + sirinaZida) &&
            (l.Y + l.Velicina/2 > gornjiZidY) &&
            (l.Y - l.Velicina/2 < gornjiZidY + gornjiZidVisina)) {
            fill(color(255,0,0));
            rect(gornjiZidX, gornjiZidY, sirinaZida, gornjiZidVisina, 7);
            SmanjiZivot(l);
            zid[4] = 1; // dogodio se sudar s tim zidom
        }
        // ako se sudari s donjim zidom
        if ((l.X + l.Velicina/2 > donjiZidX) &&
            (l.X - l.Velicina/2 < donjiZidX + sirinaZida) &&
            (l.Y + l.Velicina/2 > donjiZidY) &&
            (l.Y - l.Velicina/2 < donjiZidY + donjiZidVisina)){
            fill(color(255,0,0));
            rect(donjiZidX, donjiZidY, sirinaZida, donjiZidVisina, 7);
            SmanjiZivot(l);
            zid[4]=1; // dogodio se sudar s tim zidom
          }

        if (l.X > (zid[0] + sirinaZida) && sudar == 0) {
            // samo jedanput brojimo jedan zid
            sudar = 1;
            zid[4] = 1;
            rezultat++; //ovaj if se izvrši i kada nemamo sudar
        }
    }
}
