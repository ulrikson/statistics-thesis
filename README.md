# How To
1. cmd(ctrl)-shift-p och skriv 'Git: Clone'
2. Kopiera repository URL (https://github.com/ulrikson/statistics-thesis): tryck på "Code" (grön knapp) och kopiera länken under HTTPS
3. Klistra in i rutan i VS Code
4. Välj vart du vill ha projektet lokalt. Jag har en mapp som heter "code" på skrivbordet tex
5. Voila uppsatt!

## Varför?
- Enkelt att dela kod med varandra. GitHub ser automatiskt till att jag har din senaste kod och du min, utan att vi behöver skicka kod mellan varandra
- Om man gör massa ändringar, sparar och sen vill gå tillbaka (tänk typ du ändrar något, gör 100 saker till och sen ångrar dig), då (om du pushat till github) kan du gå tillbaka och se hur koden såg ut innan (man kan inte gå tillbaka hur långt som helst i VS Code)
- Bra att kunna, nästan alla organisationer använder det
- Du kan enkelt dela din kod med t.ex. en rekryterare + det uppfattas som mer seriöst eftersom GitHub är branschstandard för nästan allt kodrelaterat

## Löpande uppdateringar
När du sen öppnar projektet (mappen 'statistic-thesis') i VS Code kommer du se att det längst ner till vänster i VS Code står "master" och en "snurra"
- Master är branchen vi jobbar i (egentligen inte så relevant)
- Snurran kommer att visa om det finns uppdateringar att ladda ner / ladda upp (det senare när du gjort ändringar)
- Pröva att ändra i t.ex. main.py, spara så kommer du se att det dyker upp en 1:a i sidomenyn till vänster, klicka den
- main-py dyker nu upp under "changes". Här ligger alla ändringar du gjort men inte "publicerat" (= skickat till Github)
- hovra changes så syns ett plus, tryck pluset så "stageas" dina ändringar (bara ett mellansteg man måste göra)
- skriv sedan i meddelanderutan ovan vad du gjort (ex "testtesttest") och tryck cmd(ctrl)-enter. Dina ändringar är nu redo att skickas till GitHub, men ngn annan kan inte se det
- Längst ner till vänster på skärmen (samma ställe som vi snackade om ovan) kmr du nu se en 1a med pil uppåt. Det betyder att du har någonting att skicka till molnet. Tryck på det. Efter några sekunder försvinner 1an och alla ändringar är skickade till GitHub och jag kan se dina ändringar.
