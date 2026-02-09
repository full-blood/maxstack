# 🚀 Guide de Démarrage Rapide MaxStack

## Installation en 3 Minutes

### 1️⃣ Installation

1. **Téléchargez** le dossier `MaxStack`
2. **Ouvrez 3ds Max**
3. Appuyez sur **F11** pour ouvrir MAXScript Listener
4. Tapez : **MaxScript → Run Script**
5. Naviguez jusqu'au dossier `MaxStack`
6. Sélectionnez **`installer.ms`**
7. Cliquez sur **Ouvrir**

✅ MaxStack est maintenant installé !

### 2️⃣ Premier Lancement

1. **Redémarrez 3ds Max**
2. Le menu **MaxStack** apparaît dans la barre de menu
3. Explorez les catégories :
   - **Material** → Scripts liés aux matériaux
   - **Transform** → Scripts de transformation

### 3️⃣ Utilisation

**Exemple 1 : Paste Clipboard Image**
1. Copiez une image (Ctrl+C)
2. Sélectionnez un objet dans 3ds Max
3. Menu MaxStack → Material → Paste Clipboard Img
4. L'image est appliquée comme texture !

**Exemple 2 : Smart Mirror**
1. Sélectionnez un objet
2. Menu MaxStack → Transform → Mirror
3. Choisissez l'axe (X, Y ou Z)
4. Cochez "Create Copy" si vous voulez une copie
5. Cliquez sur "Mirror Selection"

## 📁 Structure Installée

```
%USERPROFILE%/Documents/3dsMax/scripts/
└── MaxStack/
    ├── icons/          ← Icônes des scripts
    ├── scripts/        ← Vos scripts MaxScript
    ├── update/         ← Système de mise à jour
    ├── main.ms
    ├── menu-builder.ms
    └── version.txt
```

## ➕ Ajouter Vos Propres Scripts

### Méthode Simple

1. Allez dans `%USERPROFILE%/Documents/3dsMax/scripts/MaxStack/scripts/`
2. Copiez votre script `.ms` dans ce dossier
3. Nommez-le au format : `_MyTools_CATEGORY_ActionName.ms`
4. (Optionnel) Ajoutez une icône `.png` dans le dossier `icons/`
5. Redémarrez 3ds Max

**Le script apparaît automatiquement dans le menu !**

### Catégories Recommandées

- `Modeling` - Outils de modélisation
- `Transform` - Transformations et manipulation
- `Material` - Matériaux et textures
- `Animation` - Animation et keyframes
- `Rendering` - Rendu et éclairage
- `Utilities` - Utilitaires divers

## 🔄 Mises à Jour Automatiques

Si vous utilisez GitHub :

1. Les mises à jour sont vérifiées **au démarrage**
2. Une popup s'affiche si une nouvelle version existe
3. Cliquez sur **Oui** pour télécharger
4. Redémarrez 3ds Max

## 🎨 Créer Vos Icônes

### Outils Recommandés

- **Photoshop, GIMP** : Créez une image 24x24 pixels
- **Icons8, Flaticon** : Téléchargez des icônes gratuites
- **Online Tools** : favicon.io, canva.com

### Spécifications

- **Taille** : 16x16 ou 24x24 pixels
- **Format** : PNG avec transparence
- **Nom** : Identique au script (ex: `_MyTools_Material_PasteClipboardImg.png`)

## 🛠️ Dépannage Rapide

### Le menu n'apparaît pas
→ Vérifiez MAXScript Listener (F11) pour les erreurs  
→ Relancez l'installateur  
→ Redémarrez 3ds Max

### Un script ne fonctionne pas
→ Testez le script individuellement (Run Script)  
→ Vérifiez les erreurs dans MAXScript Listener (F11)  
→ Vérifiez la syntaxe MaxScript

### Les icônes sont absentes
→ Vérifiez que le nom de l'icône = nom du script  
→ Vérifiez que c'est bien un fichier PNG  
→ Redémarrez 3ds Max

## 📚 Aller Plus Loin

- **README.md** : Documentation complète
- **GITHUB_GUIDE.md** : Publier sur GitHub
- **SCRIPT_TEMPLATE.ms** : Template pour nouveaux scripts

## 💡 Exemples de Scripts à Créer

### Script Simple (sans interface)
```maxscript
-- _MyTools_Utilities_SelectByName.ms
macroScript MyTools_SelectByName category:"MyTools"
(
    local searchName = getUserInput "Rechercher les objets contenant:"
    if searchName != undefined then
        select (for obj in objects where matchPattern obj.name pattern:("*"+searchName+"*") collect obj)
)
```

### Script avec Interface
```maxscript
-- _MyTools_Modeling_RandomScale.ms
macroScript MyTools_RandomScale category:"MyTools"
(
    rollout RandomScaleRollout "Random Scale"
    (
        spinner spn_min "Min:" range:[0,100,80] type:#float
        spinner spn_max "Max:" range:[0,100,120] type:#float
        button btn_apply "Apply"
        
        on btn_apply pressed do
        (
            for obj in selection do
            (
                local factor = random spn_min.value spn_max.value
                obj.scale = [factor,factor,factor]
            )
        )
    )
    createDialog RandomScaleRollout 150 120
)
```

## ✅ Checklist Premier Lancement

- [ ] Installateur exécuté
- [ ] 3ds Max redémarré
- [ ] Menu MaxStack visible
- [ ] Scripts exemples testés
- [ ] README.md lu
- [ ] Premier script personnel ajouté

## 🎓 Ressources

- MaxScript Documentation : https://help.autodesk.com/view/3DSMAX/2024/ENU/
- MaxScript Reference : Aide → MaxScript Help
- Community : forums.autodesk.com

---

**Besoin d'aide ?** Consultez le README.md complet ou ouvrez une issue sur GitHub.

**Version :** 1.0.0  
**Dernière mise à jour :** 2024
