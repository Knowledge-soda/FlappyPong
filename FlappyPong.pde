import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;


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

// početna gravitacija
float gravitacija = 0.3;

// otpor zraka i otpor podloga
float otporZraka = 0.0001;
float otporPodlogeVert = 0.35;
float otporPodlogeHoriz = 0.3;

// reket info
color reketBoja = color(0);
float reketSirina = 100;
int reketDuzina = 10;


//zidovi info
int BrzinaZidova = 5;
int intervalDodavanjaZidova = 1000;
float zadnjeVrijemeDodavanja = 0;
int minUdaljenostZidova = 200;
int maxUdaljenostZidova = 300;
int sirinaZida = 80;
color bojaZidova = color(0,128,0);
ArrayList<int[]> zidovi = new ArrayList<int[]>();

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

//font
PFont font;

//slika 
PImage ptica;
int x=0;
float y=150;

/********* KLASA LOPTICA *********/
class Loptica { 
  float lopticaX,lopticaY; 
  int lopticaVelicina;
  int lopticaBoja; 
  float lopticaBrzinaVert;
  float lopticaBrzinaHorizon;
  
  Loptica(float x,float y) {  
    lopticaX = x; 
    lopticaY = y; 
    lopticaVelicina = 20;
    lopticaBoja = color(77,0,75);
    lopticaBrzinaVert = 0;
    lopticaBrzinaHorizon = 0;
  }
}

/********* SETUP DIO *********/

void setup() {
    size(600, 600);
    
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
      ZaslonIgre1();
    } 
    else if (zaslon == 2) {
      ZaslonKrajIgre();
    }
    else if(zaslon == 3){
      ZaslonInstrukcije();
    }
    else if(zaslon == 4){
      ZaslonIgre2();                                                                           
    }
     else if(zaslon == 5){
      ZaslonIgre3();
    }
    println(frameRate);
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
    
    pjesmica.play();
    
    NacrtajPticicu();
    NacrtajLopticu(loptica1);
    PrimijeniGravitaciju(loptica1);
    ZadrziLopticuNaZaslonu(loptica1);
}

void ZaslonIgre1() {
    pjesmica.play();  
    background(110,193,248);
    
    NacrtajLopticu(loptica1); 
    PrimijeniGravitaciju(loptica1);
    ZadrziLopticuNaZaslonu(loptica1);
    NacrtajReket();
    OdbijanjeLopticeOdReketa(loptica1);  
    PrimijeniHorizontalnuBrzinu(loptica1);
    DodavanjeZidova();
    for (int i = 0; i < zidovi.size(); i++) {
        IzbrisiZid(i);
        PomakniZid(i);
        CrtajZid(i);
        SudaranjeSaZidom(i,loptica1);
    }
    IscrtajLinijuZivota(loptica1);  
    ispisiRezultat();
    
    // inicijaliziraj varijable na pocetno
    PrintTop5 = 1;
    trazeni = 5;
    korisnikIme = "";
    odrediCiglice = 1;
}

void ZaslonKrajIgre() {
    //Da bi pjesmica krenula ispočetka u novoj igri
    pjesmica.pause();
    pjesmica.rewind();   
    loptica_zvuk.play();
    
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

void ZaslonIgre2(){
    background(255);
    IspisiVrijeme(startVrijeme);
    //samo jednom želimo odrediti boje ciglica    
    if(odrediCiglice == 1){
      OdrediCiglice();
      odrediCiglice = 0;
    }
    NacrtajCiglice();
    NacrtajLopticu(loptica1);   
    NacrtajReket();
    PrimijeniGravitaciju(loptica1);
    ZadrziLopticuNaZaslonu(loptica1);
    OdbijanjeLopticeOdReketa(loptica1);  
    PrimijeniHorizontalnuBrzinu(loptica1);
    SudaranjeSaCiglicama(loptica1);
    // kraj igre
    if( ciglice.size() == 0 ){       
        krajVrijeme = millis();
        ukupnoVrijemeSec = (krajVrijeme - startVrijeme)/1000;
        // ukupnom rezultatu dodajemo broj obrnuto proporacionalan vremenu potrebnom za pogađanje svih ciglica 
        rezultat += round(150 - 2 * ukupnoVrijemeSec); 
        //****************
        zaslon = 5; 
        startVrijeme2 = millis();
        odrediCiglice2 = 1;
    }
}

void ZaslonIgre3(){  
    background(255);
    IspisiVrijeme(startVrijeme2);
    //samo jednom želimo odrediti boje ciglica    
    if(odrediCiglice2 == 1){
      OdrediCiglice2();
      odrediCiglice2 = 0;
    }    
    NacrtajCiglice();
    NacrtajLopticu(loptica1);
    NacrtajLopticu(loptica2);
    NacrtajReket2();
    PrimijeniGravitaciju(loptica1);
    PrimijeniGravitaciju(loptica2);
    ZadrziLopticuNaZaslonu(loptica1);
    ZadrziLopticuNaZaslonu(loptica2);
    OdbijanjeLopticeOdReketa2(loptica1);
    OdbijanjeLopticeOdReketa2(loptica2);
    PrimijeniHorizontalnuBrzinu(loptica1);
    PrimijeniHorizontalnuBrzinu(loptica2);
    SudaranjeSaCiglicama(loptica1);
    SudaranjeSaCiglicama(loptica2);
    // kraj igre    
    if( ciglice.size()==0){
        zaslon = 2;
        krajVrijeme2 = millis();
        ukupnoVrijemeSec2 = (krajVrijeme2 - startVrijeme2)/1000;
        // ukupnom rezultatu dodajemo broj obrnuto proporacionalan vremenu potrebnom za pogađanje svih ciglica 
        rezultat += round(150 - 2 * ukupnoVrijemeSec2); 
    }
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
      loptica1=new Loptica(100,300);      
      zaslon = 1;
    }
    
    // ako smo na zaslonu za kraj igre, postavi varijable na početno i ponovno pokreni igru 1
    else if (zaslon == 2){
      //Da bi pjesmica krenula ispočetka u novoj igri
      loptica_zvuk.pause();
      loptica_zvuk.rewind(); 
      
      rezultat = 0;
      zivot = maxZivot;
      loptica1=new Loptica(100,100);
      loptica2=new Loptica(100,500);      
      zadnjeVrijemeDodavanja = 0;
      zidovi.clear();
      zaslon = 1;
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

void NacrtajLopticu(Loptica l) {
    fill(l.lopticaBoja);
    ellipse(l.lopticaX, l.lopticaY, l.lopticaVelicina, l.lopticaVelicina);
}

void PrimijeniGravitaciju(Loptica l) {
    // brzinu loptice povećava utjecaj gravitacije, a smanjuje otpor zraka
    // vertikalni položaj loptice mijenja se za brzinu loptice
    l.lopticaBrzinaVert += gravitacija;
    l.lopticaBrzinaVert -= (l.lopticaBrzinaVert * otporZraka) * abs(l.lopticaBrzinaVert);
    l.lopticaY += l.lopticaBrzinaVert;      
}

void OdbijOdDna(float podloga,Loptica l) {
    // najdonju točku loptice postavi na dno podloge, promijeni smjer brzine (pomonoži s -1) 
    // smanji brzinu za otpor podloge
    l.lopticaY = podloga - l.lopticaVelicina/2;
    l.lopticaBrzinaVert -= (l.lopticaBrzinaVert * otporPodlogeVert);
    l.lopticaBrzinaVert *= -1;
}

void OdbijOdStropa(float podloga,Loptica l) {
    l.lopticaY = podloga + l.lopticaVelicina/2;
    l.lopticaBrzinaVert -= (l.lopticaBrzinaVert * otporPodlogeVert);
    l.lopticaBrzinaVert *= -1;
}

void PrimijeniHorizontalnuBrzinu(Loptica l){
    l.lopticaX += l.lopticaBrzinaHorizon;
    l.lopticaBrzinaHorizon -= (l.lopticaBrzinaHorizon * otporZraka) * abs(l.lopticaBrzinaHorizon);
}

void OdbijOdLijevogRuba(float podloga,Loptica l){
    l.lopticaX = podloga + l.lopticaVelicina/2;
    l.lopticaBrzinaHorizon -= (l.lopticaBrzinaHorizon * otporPodlogeHoriz);
    l.lopticaBrzinaHorizon *= -1;
}

void OdbijOdDesnogRuba(float podloga,Loptica l){
    l.lopticaX = podloga-(l.lopticaVelicina/2);
    l.lopticaBrzinaHorizon *= -1;
    l.lopticaBrzinaHorizon -= (l.lopticaBrzinaHorizon * otporPodlogeHoriz);
}

void ZadrziLopticuNaZaslonu(Loptica l) {
    // ako loptica padne na pod, tj. ako najdonja točka loptice bude veća od visine ekrana
    if (l.lopticaY + l.lopticaVelicina/2 > height) { 
      OdbijOdDna(height,l);
    }
    // ako loptica dotakne strop
    if (l.lopticaY - l.lopticaVelicina/2 < 0) {
      OdbijOdStropa(0,l);
    }
    // ako loptica dotakne lijevi rub
    if (l.lopticaX - l.lopticaVelicina/2 < 0){
      OdbijOdLijevogRuba(0,l);
    }
    // ako loptica dotakne desni rub
    if (l.lopticaX + l.lopticaVelicina/2 > width){
      OdbijOdDesnogRuba(width,l);
    }
}

void NacrtajReket(){
    fill(reketBoja);
    rectMode(CENTER);
    rect(mouseX, mouseY, reketSirina, reketDuzina);
}

void OdbijanjeLopticeOdReketa(Loptica l) {
    // pomak misa u novom u odnosu na prethodni frame
    float pomakMisa = mouseY - pmouseY;  
    // ako se loptica nalazi unutar širine reketa
    if ((l.lopticaX + l.lopticaVelicina/2 > mouseX- reketSirina/2) && (l.lopticaX - l.lopticaVelicina/2 < mouseX + reketSirina/2)) {
      // ako je udaljenost središta loptice i središta reketa manja od pola veličine loptice i pomaka miša
      // tj. ako je došlo do sudara loptice i reketa 
      if (dist(l.lopticaX, l.lopticaY, l.lopticaX, mouseY) <= l.lopticaVelicina/2 + abs(pomakMisa)) {
          OdbijOdDna(mouseY,l);       
          // povećaj brzinu i položaj loptice u odnosu na jačinu udara
          if (pomakMisa < 0) {
            l.lopticaY += pomakMisa;
            l.lopticaBrzinaVert += pomakMisa;
          }        
          //ide li loptica lijevo ili desno ovisi o točki reketa na koju je pala
          l.lopticaBrzinaHorizon = (l.lopticaX - mouseX)/10; // 1/10 vrijednosti najprirodnije
      }
    }
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
  if ((l.lopticaX + l.lopticaVelicina/2 > gornjiZidX) &&
      (l.lopticaX - l.lopticaVelicina/2 < gornjiZidX + sirinaZida) &&
      (l.lopticaY + l.lopticaVelicina/2 > gornjiZidY) && 
      (l.lopticaY - l.lopticaVelicina/2 < gornjiZidY + gornjiZidVisina)) 
      { 
          fill(color(255,0,0));
          rect(gornjiZidX, gornjiZidY, sirinaZida, gornjiZidVisina, 7);
          SmanjiZivot(l); 
          zid[4] = 1; // dogodio se sudar s tim zidom
      }
  // ako se sudari s donjim zidom
  if ((l.lopticaX + l.lopticaVelicina/2 > donjiZidX) &&
      (l.lopticaX - l.lopticaVelicina/2 < donjiZidX + sirinaZida) &&
      (l.lopticaY + l.lopticaVelicina/2 > donjiZidY) &&
      (l.lopticaY - l.lopticaVelicina/2 < donjiZidY + donjiZidVisina)) 
      {
          fill(color(255,0,0));
          rect(donjiZidX, donjiZidY, sirinaZida, donjiZidVisina, 7);
          SmanjiZivot(l); 
          zid[4]=1; // dogodio se sudar s tim zidom
      }
  
  if (l.lopticaX > (zid[0] + sirinaZida) && sudar == 0) {
      // samo jedanput brojimo jedan zid
      sudar = 1; 
      zid[4] = 1;
      rezultat++; //ovaj if se izvrši i kada nemamo sudar
  }
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
    rect(l.lopticaX- sirinaLinijeZivota/2, l.lopticaY - 30, sirinaLinijeZivota, 5);
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
    rect(l.lopticaX-sirinaLinijeZivota/2, l.lopticaY - 30, sirinaLinijeZivota * zivot/maxZivot, 5);
}

void SmanjiZivot(Loptica l){
    zivot -= 1;
    if (zivot <= 0){
      // kraj igre 1, prijedi na igru 2
      //****************
      zaslon = 4;
      // postavi koordinate za lopticu u novoj igri
      l.lopticaX = height/2; l.lopticaY = 400;
      // odredi startVrijeme za drugu igru
      startVrijeme = millis();
    }
}

/********* FUNKCIJE 2. IGRE *********/ 

void NacrtajReket2(){
    fill(reketBoja);
    rectMode(CENTER);
    rect(mouseX,height - 20 , reketSirina, reketDuzina);
}
  
 void OdbijanjeLopticeOdReketa2(Loptica l) {
    // pomak misa u novom u odnosu na prethodni frame
    float pomakMisa = mouseX - pmouseX;  
    // ako se loptica nalazi unutar širine reketa
    if ((l.lopticaX + l.lopticaVelicina/2 > mouseX- reketSirina/2) && (l.lopticaX - l.lopticaVelicina/2 < mouseX + reketSirina/2)) {
      // ako je udaljenost središta loptice i središta reketa manja od pola veličine loptice i pomaka miša
      // tj. ako je došlo do sudara loptice i reketa 
      if (dist(l.lopticaX, l.lopticaY, l.lopticaX, height - 50) <= l.lopticaVelicina/2 + abs(pomakMisa)) {
          OdbijOdDna2(height - 20,l);       
          // povećaj brzinu i položaj loptice u odnosu na jačinu udara
          if (pomakMisa < 0) {
            l.lopticaX += (l.lopticaX - mouseX)/10;
            l.lopticaBrzinaVert += pomakMisa;
          }        
          //ide li loptica lijevo ili desno ovisi o točki reketa na koju je pala
          l.lopticaBrzinaHorizon = pomakMisa;// 1/10 vrijednosti najprirodnije
      }
    }
}

  void OdbijOdDna2(float podloga,Loptica l) {
    // najdonju točku loptice postavi na dno podloge, promijeni smjer brzine (pomonoži s -1) 
    // smanji brzinu za otpor podloge
    l.lopticaY = podloga - l.lopticaVelicina/2;
    l.lopticaBrzinaVert -= (l.lopticaBrzinaVert * otporPodlogeVert);
    l.lopticaBrzinaVert *= -0.5;
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

void OdrediCiglice2(){    
    // ciglice ćemo pamtiti u listu 
    // sve će biti iste širine (50) i dužine (10)
    for(int i = 0; i < 12; i++)
      for(int j = 0; j < 8; j++){
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
  for(int i = ciglice.size() - 1; i >= 0; i-- ){
    int[] ciglica = ciglice.get(i);  
    // ako se sudari s ciglicom
    if ((l.lopticaX + l.lopticaVelicina/2 > ciglica[0]) &&
        (l.lopticaX - l.lopticaVelicina/2 < ciglica[0] + ciglaSirina) &&
        (l.lopticaY + l.lopticaVelicina/2 > ciglica[1]) && 
        (l.lopticaY - l.lopticaVelicina/2 < ciglica[1] + ciglaDuzina)) 
        { 
            //OdbijOdStropa(ciglica[1]);
            l.lopticaBrzinaVert -= (l.lopticaBrzinaVert * otporPodlogeVert);
            l.lopticaBrzinaVert *= -1;
            ciglice.remove(i);
            break;
        }
  }
}

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
