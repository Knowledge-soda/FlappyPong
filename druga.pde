void ZaslonIgre2(){
    background(255);
    IspisiVrijeme(startVrijeme);
    //samo jednom želimo odrediti boje ciglica
    if(odrediCiglice == 1){
      OdrediCiglice();
      odrediCiglice = 0;
    }
    NacrtajCiglice();
    loptica1.Nacrtaj();
    NacrtajReket();
    loptica1.PrimijeniGravitaciju();
    loptica1.ZadrziNaZaslonu();
    loptica1.OdbijOdReketa();
    loptica1.PrimijeniHorizontalnuBrzinu();
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


