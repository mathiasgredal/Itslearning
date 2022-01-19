# Itslearning Fileprovider
*Advarsel: Dette program er Work-In-Progress og leveres uden garanti af nogen art. Forfatteren kan under ingen omstændigheder holdes til ansvar for nogle krav, skader, datatab m.m. i forbindelse med anvendelse af denne software, i videst muligt omfang tilladt ved lov.*

Dette er et program til MacOS, som benyttes til at tilgå ressourcer i Itslearning igennem Finder.

<img width="1220" alt="image" src="https://user-images.githubusercontent.com/20731972/149433369-68473b73-a921-4f5f-819d-b51d7a8f7bd0.png">




**Installation af program(2 valgmuligheder):**
1. Download nyeste version fra releases: https://github.com/mathiasgredal/Itslearning/releases/
2. Kompiler selv med XCode(se næste afsnit)

**Byg selv programmet:**
- Tjek at XCode og git er installeret.
- Download en kopi at koden: `git clone https://github.com/mathiasgredal/Itslearning.git`
- Åben projektet i XCode
- Sæt eget team til signering af programmet for både Itslearning og ItslearningFileProvider og noter det nye app-gruppe id
  - <img width="700" alt="Screenshot 2022-01-14 at 01 53 25" src="https://user-images.githubusercontent.com/20731972/149432138-f34c1b35-2ba0-4a6a-a797-ec8b3f6fb64a.png">
- Find på et nyt bundle-id og sæt det for både Itslearning og ItslearningFileProvider
  - bundle-id for ItslearningFileProvider skal være prefikset af bundle-id for Itslearning
- Indsæt det nye app-gruppe id i filen `ItslearningAPI/Defaults.swift`
  - <img width="700" alt="Screenshot 2022-01-14 at 01 53 25" src="https://user-images.githubusercontent.com/20731972/149432558-8cdb1fdf-a28b-4ee4-81f7-d5ab975a14e7.png">
- Tryk på pilen i øverste venstre hjørne for at bygge og afvikle projektet

**Brugsinstrukser:**
- Login
- Tryk på "Register FP" for at slå fileprovideren til
- Åben Finder, hvor der burde være en ny mappe i venstre side
- Eftersom programmet er lidt ustabilt, kan det være nødvendigt at genstarte det eller slå fileprovideren til og fra.
