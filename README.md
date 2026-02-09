# MaxStack - Gestionnaire de Scripts 3ds Max

## 🎯 Description

MaxStack est un système automatisé pour gérer et organiser vos scripts 3ds Max. Il offre :

- ✅ Installation automatique
- ✅ Mise à jour automatique depuis GitHub
- ✅ Création automatique de menus
- ✅ Organisation par catégories
- ✅ Support des icônes personnalisées
- ✅ Chargement au démarrage de 3ds Max

## 📁 Structure du Projet

```
MaxStack/
├── icons/                                          # Icônes des scripts
│   ├── _MyTools_Material_PasteClipboardImg.png
│   └── _MyTools_Transform_Mirror.png
│   └── list.txt                                    # Liste des icônes pour la mise à jour
├── scripts/                                        # Vos scripts MaxScript
│   ├── _MyTools_Material_PasteClipboardImg.ms
│   └── _MyTools_Transform_Mirror.ms
│   └── list.txt                                    # Liste des scripts pour la mise à jour
├── update/
│   └── update.ms                                   # Système de mise à jour
├── installer.ms                                    # Script d'installation
├── main.ms                                         # Script principal de chargement
├── menu-builder.ms                                 # Générateur de menu automatique
├── version.txt                                     # Version actuelle (ex: 1.0.0)
└── README.md                                       # Cette documentation
```

## 🔤 Convention de Nommage

### Scripts et Icônes

**Format recommandé :** `_Prefix_Category_ActionName.ms`

**Exemples :**
- `_MyTools_Material_PasteClipboardImg.ms` → Catégorie "Material", Action "Paste Clipboard Img"
- `_MyTools_Transform_Mirror.ms` → Catégorie "Transform", Action "Mirror"
- `_MyTools_Modeling_QuickBevel.ms` → Catégorie "Modeling", Action "Quick Bevel"

**Icônes :** Même nom que le script, extension `.png`
- Script : `_MyTools_Material_PasteClipboardImg.ms`
- Icône : `_MyTools_Material_PasteClipboardImg.png`

### Organisation Automatique

Le système crée automatiquement :
- Un menu principal "MaxStack"
- Des sous-menus par catégorie (Material, Transform, Modeling, etc.)
- Des actions associées à chaque script avec icône si disponible

## 🚀 Installation

### 1. Installation Locale

1. Téléchargez ou clonez le projet
2. Dans 3ds Max, allez dans **MaxScript → Run Script**
3. Sélectionnez `installer.ms`
4. Le script s'installe dans `%USERPROFILE%\Documents\3dsMax\scripts\MaxStack`
5. Un fichier de démarrage automatique est créé dans `startup/`

### 2. Configuration GitHub (pour les mises à jour)

Si vous voulez héberger votre projet sur GitHub pour les mises à jour automatiques :

1. Créez un repository GitHub (ex: `maxstack`)
2. Uploadez tous les fichiers dans ce repository
3. Modifiez `update.ms` ligne 107 : remplacez `full-blood/maxstack` par votre `username/repository`
4. Assurez-vous que le repository est **public**

## 🔄 Mise à Jour

### Mise à jour automatique

Au démarrage de 3ds Max, le système vérifie automatiquement les mises à jour sur GitHub.

### Mise à jour manuelle

Dans le menu MaxStack, cliquez sur "Vérifier les mises à jour" (si vous l'ajoutez au menu).

### Processus de mise à jour

1. Le système compare la version locale (`version.txt`) avec la version GitHub
2. Si une nouvelle version est disponible, il propose de télécharger
3. Les fichiers sont téléchargés et installés automatiquement
4. Redémarrez 3ds Max pour appliquer les changements

## 📝 Ajouter de Nouveaux Scripts

### Méthode 1 : Ajout Local

1. Placez votre script `.ms` dans le dossier `scripts/`
2. Placez l'icône `.png` (optionnelle) dans le dossier `icons/`
3. Relancez 3ds Max ou exécutez `main.ms`

### Méthode 2 : Ajout avec Mise à Jour GitHub

1. Ajoutez votre script dans `scripts/`
2. Ajoutez le nom du script dans `scripts/list.txt` :
   ```
   _MyTools_Material_PasteClipboardImg.ms
   _MyTools_Transform_Mirror.ms
   _MyTools_NEW_SCRIPT.ms  ← Nouvelle ligne
   ```

3. Ajoutez l'icône dans `icons/` (si applicable)
4. Ajoutez le nom de l'icône dans `icons/list.txt` :
   ```
   _MyTools_Material_PasteClipboardImg.png
   _MyTools_Transform_Mirror.png
   _MyTools_NEW_SCRIPT.png  ← Nouvelle ligne
   ```

5. Incrémentez la version dans `version.txt` :
   ```
   1.0.1
   ```

6. Commitez et pushez sur GitHub
7. Les utilisateurs recevront automatiquement la mise à jour

## 🛠️ Fichiers Principaux

### installer.ms
- Supprime l'ancienne installation
- Crée la structure de dossiers
- Copie tous les fichiers
- Crée le script de démarrage automatique

### main.ms
- Charge le système de mise à jour
- Vérifie les mises à jour
- Génère le menu automatiquement
- Charge tous les scripts

### menu-builder.ms
- Scan le dossier `scripts/`
- Parse les noms de fichiers
- Crée les catégories automatiquement
- Associe les icônes
- Génère le menu dans 3ds Max

### update/update.ms
- Vérifie la version locale vs GitHub
- Télécharge les mises à jour
- Met à jour scripts, icônes et fichiers système
- Gère les erreurs de connexion

## 🎨 Icônes

### Taille Recommandée
- **16x16 pixels** ou **24x24 pixels** pour les icônes de menu
- Format **PNG** avec transparence

### Création Automatique
Si vous n'avez pas d'icône pour un script, le menu fonctionnera quand même sans icône.

## 🔍 Exemples de Scripts

### Script Basique
```maxscript
-- _MyTools_Modeling_QuickBevel.ms

macroScript MyTools_QuickBevel category:"MyTools"
(
    if selection.count > 0 then
    (
        for obj in selection do
        (
            addModifier obj (Bevel())
        )
    )
    else
        messageBox "Aucun objet sélectionné"
)
```

### Script avec Interface
```maxscript
-- _MyTools_Material_ColorPicker.ms

rollout ColorPickerRollout "Color Picker"
(
    colorpicker cp_color "Choose Color" color:[255,0,0]
    button btn_apply "Apply to Selection"
    
    on btn_apply pressed do
    (
        if selection.count > 0 then
        (
            for obj in selection do
            (
                obj.wirecolor = cp_color.color
            )
        )
    )
)

createDialog ColorPickerRollout 200 100
```

## 📋 Liste de Contrôle pour Nouveaux Scripts

- [ ] Nom de fichier au format `_Prefix_Category_ActionName.ms`
- [ ] Script fonctionne de manière autonome
- [ ] Icône créée (16x16 ou 24x24 PNG)
- [ ] Nom de l'icône = nom du script + `.png`
- [ ] Script ajouté dans `scripts/list.txt` (pour GitHub)
- [ ] Icône ajoutée dans `icons/list.txt` (pour GitHub)
- [ ] Version incrémentée dans `version.txt`

## 🔧 Dépannage

### Le menu n'apparaît pas
- Vérifiez que MaxStack est bien installé dans `%USERPROFILE%\Documents\3dsMax\scripts\MaxStack`
- Redémarrez 3ds Max
- Vérifiez les erreurs dans MAXScript Listener (F11)

### Les icônes ne s'affichent pas
- Vérifiez que les noms de fichiers correspondent exactement
- Vérifiez que les icônes sont au format PNG
- Vérifiez les chemins dans `menu-builder.ms`

### Les mises à jour ne fonctionnent pas
- Vérifiez votre connexion internet
- Vérifiez que le repository GitHub est public
- Vérifiez l'URL dans `update.ms`

### Scripts ne se chargent pas
- Ouvrez MAXScript Listener (F11) pour voir les erreurs
- Vérifiez la syntaxe de vos scripts
- Testez chaque script individuellement

## 📦 Distribution

### Pour vos utilisateurs

1. Créez un **release** sur GitHub avec un ZIP contenant :
   - `installer.ms`
   - Tous les dossiers (`scripts/`, `icons/`, `update/`)
   - `main.ms`, `menu-builder.ms`, `version.txt`

2. Instructions pour l'utilisateur :
   - Télécharger le ZIP
   - Extraire le contenu
   - Dans 3ds Max : **MaxScript → Run Script** → Sélectionner `installer.ms`
   - Redémarrer 3ds Max

## 🎓 Ressources

- [Documentation MaxScript Autodesk](https://help.autodesk.com/view/3DSMAX/2024/ENU/?guid=GUID-EBF1B07D-DC2F-4882-8F1E-C0A5AA60BF71)
- [MaxScript Reference](https://help.autodesk.com/view/3DSMAX/2024/ENU/?guid=__developer_maxscript_reference_html)

## 📄 Licence

Libre d'utilisation et de modification pour vos projets.

## 🤝 Contribution

Pour contribuer :
1. Forkez le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

---

**Version :** 1.0.0  
**Auteur :** Votre Nom  
**Dernière mise à jour :** 2024
