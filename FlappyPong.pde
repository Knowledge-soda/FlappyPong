import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import com.jogamp.newt.opengl.GLWindow;

/********* VARIJABLE *********/

// Konroliramo koji je zaslon aktivan tako što mijenjamo
// vrijednost varijable zaslon, vrijednosti su:
//
// 0: Početni zaslon
// 1: Zaslon za igricu po uzoru na Flappy Bird
// 2: Kraj igrice
// 3: Zaslon s instrukcijama
// 4: Zaslon za igricu po uzoru na Brick Breaker
// 5: Zaslon za igricu po uzoru na Brick Breaker sa dvije kuglice

int zaslon = 0;

//dvije instance klase Loptica
Loptica loptica1 = new Loptica(100,100);
Loptica loptica2 = new Loptica(100,500);

//Reket reket;

// početna gravitacija
float gravitacija = 0.3;

// otpor zraka i otpor podloga
float otporZraka = 0.00001;
float otporPodlogeVert = 0.35;
float otporPodlogeHoriz = 0.3;

// zivot i rezultat info
int maxZivot = 100;
int zivot = 100;
int sirinaLinijeZivota = 60;
int rezultat = 0;

// inicijalizacija niza ciglica, sirina i duzina jedne ciglice
ArrayList<int[]> ciglice = new ArrayList<int[]>();
int ciglaSirina = 50, ciglaDuzina = 20;

// samo jednom određujemo boje ciglica
int odrediCiglice = 1;
int odrediCiglice2 = 1;

// vrijeme početka i kraja igre 2 i 3
int startVrijeme, krajVrijeme, startVrijeme2, krajVrijeme2;
float ukupnoVrijemeSec, ukupnoVrijemeSec2;
int meduvrijemePocetak;

// test kad ispisujemo top5
int PrintTop5 = 1;
int[] topRez = new int[6];
String[] imena = new String[6];
// za provjeru da li je rezultat veći od postojećih
int trazeni = 5;

// korisničko ime te varijabla za upis imena
String korisnikIme = "", upisano = "";

//zvukovi
AudioPlayer pjesmica, loptica_zvuk, podogak_zvuk;
Minim minim;
boolean playable = true;

//font
PFont font;

//slika
PImage ptica;
int x=0;
float y=150;

Igra1 igra1;
Igra2 igra2, igra3;

/********* SETUP DIO *********/

void setup() {
    size(600, 600, P2D);
    GLWindow r = (GLWindow)surface.getNative();
    r.confinePointer(true);
    r.setPointerVisible(false);

    //Zvukovi
    minim = new Minim(this);
    pjesmica = minim.loadFile("pjesmica.mp3");
    loptica_zvuk = minim.loadFile("pingPong.mp3");
    //pogodak_zvuk = minim.loadFile("ding.mp3");
    //font
    font = loadFont("BerlinSansFBDemi-Bold-90.vlw");
    textFont(font);
    //slika
    ptica = loadImage("flappyBird.jpg");
}

/********* DRAW DIO *********/

void draw() {
    // Crta sadržaj trenutnog ekrana
    if (zaslon == 0) {
        pocetniZaslon();
    }
    else if (zaslon == 1) {
        igra1.Igraj();
    }
    else if (zaslon == 2) {
        ZaslonKrajIgre();
    }
    else if(zaslon == 3){
        ZaslonInstrukcije();
    }
    else if(zaslon == 4){
        igra2.Igraj();
    }
    else if(zaslon == 5){
        igra3.Igraj();
    }
}


/********* ZASLONI *********/

void pocetniZaslon() {
    background(255);
    fill(0,128,255);
    textSize(60);
    textAlign(CENTER);
    text("Flappy Pong", height/2, width/2);

    fill(46, 204, 113);
    textSize(20);
    text("Klikni za start!", height/2, width/2 + 50);

    fill(255,140,0);
    text("Pritisni tipku 'i' za prikaz instrukcija", height/2, width/2 + 80);

    if (pjesmica != null){
        pjesmica.play();
    }

    NacrtajPticicu();
    loptica1.Nacrtaj();
    loptica1.PrimijeniGravitaciju();
    loptica1.ZadrziNaZaslonu();
}

void ZaslonKrajIgre() {
    //Da bi pjesmica krenula ispočetka u novoj igri
    if (pjesmica != null){
        pjesmica.pause();
        pjesmica.rewind();
    }
    if (loptica_zvuk != null){
        loptica_zvuk.play();
    }

    background(255);
    textAlign(CENTER);
    fill(0,128,255);
    textSize(40);
    text("Igra je gotova", height/2, width/3 - 20);

    ispisiRezultat();

    if(PrintTop5 == 1){
        PronadiTop5();
        PrintTop5 = 0;
    }

    fill(77,0,75);
    textSize(18);
    if(trazeni != 5)
       UpisiKorisnickoIme();
    else text("Nisi u top 5. :(",  height/2, width/3 + 40);

    // ne radi unutar if, mora ovdje
    imena[trazeni] = korisnikIme;

    IspisiTop5();

    fill(46, 204, 113);
    textSize(20);
    text("Klikni za opet", height/2, width/3 + 250);
}


void ZaslonInstrukcije(){
    background(255);
    fill(46, 204, 113);
    textAlign(CENTER);
    textSize(40);
    text("INSTRUKCIJE", height/2, 40);
    fill(255,0,0);
    textSize(18);
    text("Pritisni tipke:", height/2, 80);
    fill(77,0,75);
    text("s  -  za pauziranje igre", height/2, 100);
    text("p  -  za ponovno pokretanje igre", height/2, 120);
    text("x  -  za vracanje na pocetni zaslon", height/2, 140);
    fill(255,0,0);
    text("Cilj igre 1:", height/2, 180);
    fill(77,0,75);
    text("Izbjegni sudaranje loptice sa zidom tako da je", height/2, 200);
    text("reketom odmakneš od zidova. Svako sudaranje", height/2, 220);
    text("loptice sa zidom, oduzima ti dio života. Igra 1", height/2,240);
    text("završava kada ti linija života postane bijela.", height/2, 260);
    fill(255,0,0);
    text("Cilj igre 2:", height/2, 300);
    fill(77,0,75);
    text("Pogodi sve ciglice u što manjem vremenu!", height/2, 320);
    fill(255,0,0);
    text("Cilj igre 3:", height/2, 360);
    fill(77,0,75);
    text("Uz pomocu 2 loptice pogodi sve ciglice u što manjem vremenu!", height/2, 380);
    fill(255,0,0);
    text("Reket i loptica:", height/2, 420);
    fill(77,0,75);
    text("Reket kontroliraš pomicanjem miša.", height/2, 440);
    text("Lopticu udari sredinom reketa ako želiš da ide", height/2, 460);
    text("vertikalno prema stropu, lijevim rubom reketa", height/2, 480);
    text("ako je želiš pomaknuti ulijevo, te desnim rubom", height/2, 500);
    text("reketa ako je želiš pomaknuti udesno. ", height/2, 520);

    fill(46, 204, 113);
    textSize(20);
    text("Klikni za start!", height/2, 560);
}

/********* INPUTI *********/

public void mousePressed() {
    // ako smo na početnom zaslonu ili na zaslonu s instrukcijama, nakon klika prebaci na zaslon za igru 1
    if (zaslon == 0 || zaslon == 3) {
        igra1 = new Igra1();
    }

    // ako smo na zaslonu za kraj igre, postavi varijable na početno i ponovno pokreni igru 1
    else if (zaslon == 2){
        //Da bi pjesmica krenula ispočetka u novoj igri
        if (loptica_zvuk != null){
            loptica_zvuk.pause();
            loptica_zvuk.rewind();
        }

        rezultat = 0;
        igra1 = new Igra1();
   }
}

void keyPressed() {
    if( key == 's' && zaslon == 1){
        looping=false;
        noLoop();
    }

    else if( key == 'x' && (zaslon == 1 || zaslon == 4 || zaslon == 5)){
        loptica1=new Loptica(100,300);
        zaslon = 0;
    }

    else if( key == 'p' && looping == false && zaslon == 1){
        looping = true;
        loop();
    }
    // ako stisnemo pauzu u 2. ili 3. igri moramo ignorirati vrijeme koje prođe dok traje pauza
    else if( key == 's' && (zaslon == 4 || zaslon == 5)){
        looping=false;
        noLoop();
        meduvrijemePocetak = millis();
    }
    // vrijeme u pauzi ne zbrajamo u ukupno vrijeme tako da pomaknemo statVrijeme za taj iznos vremena
    else if( key == 'p' && looping == false && (zaslon == 4 || zaslon == 5)){
        if(zaslon == 4) startVrijeme += millis() - meduvrijemePocetak;
        else if(zaslon == 5) startVrijeme2 += millis() - meduvrijemePocetak;
        looping = true;
        loop();
    }
    else if( key == 'i' && zaslon == 0){
        zaslon = 3;
    }
    else if (key == ENTER ) {
        korisnikIme = upisano;
        upisano = "";
    }
    else {
        upisano = upisano + key;
    }
}


/********* FUNKCIJE 1. IGRE *********/

void NacrtajPticicu() {
    ptica.resize(50, 50);
    image(ptica, x, y);
    x++;
    y=150+8*sin(x/2); //za dojam da ptičica leti
}


void ispisiRezultat(){
    fill(255,140,0);
    textSize(50);
    textAlign(CENTER);
    text(rezultat, height/2 , 50);
}

void IscrtajLinijuZivota(Loptica l) {
    noStroke();
    fill(236, 240, 241);
    rectMode(CORNER);
    rect(l.X- sirinaLinijeZivota/2, l.Y - 30, sirinaLinijeZivota, 5);
    if (zivot > 60) {
        fill(57,255,20);
    }
    else if (zivot > 30) {
        fill(230, 126, 34);
    }
    else {
        fill(255, 0, 0);
    }
    rectMode(CORNER);
    rect(l.X-sirinaLinijeZivota/2, l.Y - 30, sirinaLinijeZivota * zivot/maxZivot, 5);
}

void SmanjiZivot(Loptica l){
    zivot -= 1;
    if (zivot <= 0){
        // kraj igre 1, prijedi na igru 2
        //****************
        igra2 = new Igra2(2);
    }
}

/********* FUNKCIJE 2. IGRE *********/

void IspisiVrijeme(int startVrijeme){
    fill(255,140,0);
    textSize(50);
    textAlign(CENTER);
    text(str((millis()-startVrijeme)/1000), height/2 , 30);
}

/********* FUNKCIJE ZA ISPIS NA KRAJU *********/
void PronadiTop5(){
    String[] top5 = loadStrings("top5.txt");
    // zapisemo rezultate i imena iz txt u 2 odvojena niza
    for(int i = 0; i < 5; i++){
        String[] line = split(top5[i], ' ');
        topRez[i] = Integer.parseInt(line[0]);
        imena[i] = line[1];
    }
    // tražimo da li je rezultat veći od nekog u top5
    for(int i = 0; i < 5; i++)
        if(rezultat > topRez[i]){
            trazeni = i;
            break;
        }
    // ako je, ubacujemo taj rezultat i korisničko ime na odgovarajuće mjesto
    if(trazeni >= 0){
        for(int i=4; i > trazeni; i--){
            int temp = topRez[i];
            String tempIme = imena[i];
            topRez[i] = topRez[i-1];
            imena[i] = imena[i-1];
            topRez[i-1] = temp;
            imena[i-1] = tempIme;
        }
        topRez[trazeni] = rezultat;
    }
}

void IspisiTop5(){
    // zapisemo (novi) poredak ponovno u txt
    String[] top5 = new String[5];
    for(int i = 0; i < 5; i++)
        top5[i] = str(topRez[i]) + " " + imena[i];

    saveStrings("top5.txt", top5);

    // ispisi na zaslon top 5
    text("Mjesto      Ime      Rezultat", height/2, width/3 + 100);
    for(int i = 0; i < 5; i++){
        String text = str(i+1) + ".          " + imena[i] + "          " + str(topRez[i]);
        if(i == trazeni) fill(255,0,0);
        if(i == trazeni + 1) fill(77,0,75);
        text(text, height/2, width/3 + 120 + 20*i);
    }
}

void UpisiKorisnickoIme(){
    text("Upiši ime i pritisni Enter za spremi. ",  height/2, width/3 + 40);
    text("Ime: " + upisano,  height/2, width/3 + 55);
}
