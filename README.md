# 👁️ Gaze Direction & Vergence Analysis Pipeline for HRI & Surgical Ergonomics

Una pipeline in **MATLAB** per il caricamento, il preprocessing dei segnali e l'analisi statistico-spaziale di dati oculometrici 3D (Eye-Tracking). Il sistema elabora l'orientamento dello sguardo (**Azimut** ed **Elevazione**) e la profondità di fissazione (**Vergenza**) per valutare l'attenzione visiva e il carico cognitivo dell'operatore in compiti complessi.

---

## 🎯 Contestualizzazione Biomedica & Robotica

Questo progetto trova applicazione diretta nei settori **Biomedical Engineering** e **Medical Robotics**:
- **Chirurgia Robotica Assistita (HRI):** Sviluppo di interfacce di controllo *hands-free* per il puntamento automatico dell'endoscopio/telecamera chirurgica basato sul punto di fissazione dello sguardo.
- **Ergonomia Cognitiva in Sala Operatoria:** Valutazione della fatica visiva, della concentrazione e della mappa di attenzione del chirurgo durante procedure mininvasive lunghi.
- **Signal Processing di dati biometrici:** Pulizia e rettifica temporale di segnali continui ad alta frequenza soggetti a disconnessioni o artefatti.

---

## 🛠️ Architettura e Funzionalità Principali

1. **Preprocessing del Segnale (`function/straighten.m`):** Algoritmo per la rettifica e la continuità temporale dei dati oculometrici grezzi, rimuovendo salti e discontinuità nei timestamp.
2. **Heatmap Spaziali 2D (`function/plot_2d_hist.m`):** Mappatura della densità di fissazione su un campo visivo discretizzato ($32 \times 32$ bin, range $\pm 50^\circ$) con inversione assi fisiologica per la rappresentazione dello spazio visivo reale.
3. **Analisi della Vergenza (Profondità):** Estrazione statistica e confronto (Boxplot, Mediana) della vergenza oculare in ambienti Indoor (focus da vicino) vs Outdoor (focus all'infinito).
4. **Analisi di Dispersione (Varianza Spaziale):** Valutazione della dispersione angolare orizzontale e verticale per identificare pattern di ricerca visiva.

---

## 📁 Struttura della Repository

├── function/
│   ├── straighten.m             # Algoritmo di correzione discontinuità temporali del segnale
│   └── plot_2d_hist.m           # Generatore di heatmap 2D di densità visiva
├── gaze_direction_optimized.m   # Script principale di acquisizione, elaborazione e plot
├── .gitignore                    # Esclusione automatica di dataset pesanti (.mat, .xlsx)
└── README.md                    # Documentazione tecnica del progetto
