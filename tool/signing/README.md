# Firma dell'APK

Per ora ogni build viene firmata con una chiave temporanea creata da GitHub
Actions al momento della compilazione. Nessuna chiave è salvata nel repository.

Conseguenza: per installare una nuova versione bisogna prima disinstallare
quella vecchia. Quando servirà aggiornare senza disinstallare, si potrà
salvare una chiave fissa nei "Secrets" del repository.
