void ZaslonIgre3(){
    background(255);
    IspisiVrijeme(startVrijeme2);
    //samo jednom želimo odrediti boje ciglica
    if(odrediCiglice2 == 1){
      OdrediCiglice2();
      odrediCiglice2 = 0;
    }
    NacrtajCiglice();
    loptica1.Nacrtaj();
    loptica2.Nacrtaj();
    NacrtajReket2();
    loptica1.PrimijeniGravitaciju();
    loptica2.PrimijeniGravitaciju();
    loptica1.ZadrziNaZaslonu();
    loptica2.ZadrziNaZaslonu();
    loptica1.OdbijOdReketa2();
    loptica2.OdbijOdReketa2();
    loptica1.PrimijeniHorizontalnuBrzinu();
    loptica2.PrimijeniHorizontalnuBrzinu();
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
