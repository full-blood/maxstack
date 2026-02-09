# Guide de Déploiement GitHub pour MaxStack

## 🌐 Configuration GitHub

### Étape 1 : Créer le Repository

1. Allez sur [GitHub](https://github.com)
2. Cliquez sur **New Repository**
3. Nommez-le `maxstack` (ou autre nom)
4. Sélectionnez **Public** (important pour les mises à jour)
5. Cochez **Add a README file**
6. Cliquez sur **Create repository**

### Étape 2 : Structure des Fichiers sur GitHub

Votre repository doit avoir cette structure exacte :

```
maxstack/
├── icons/
│   ├── _MyTools_Material_PasteClipboardImg.png
│   ├── _MyTools_Transform_Mirror.png
│   └── list.txt
├── scripts/
│   ├── _MyTools_Material_PasteClipboardImg.ms
│   ├── _MyTools_Transform_Mirror.ms
│   └── list.txt
├── update/
│   └── update.ms
├── installer.ms
├── main.ms
├── menu-builder.ms
├── version.txt
└── README.md
```

### Étape 3 : Créer les Fichiers de Liste

#### scripts/list.txt
```
_MyTools_Material_PasteClipboardImg.ms
_MyTools_Transform_Mirror.ms
```

#### icons/list.txt
```
_MyTools_Material_PasteClipboardImg.png
_MyTools_Transform_Mirror.png
```

**Important :** Un fichier par ligne, pas de ligne vide à la fin.

### Étape 4 : Uploader les Fichiers

#### Option A : Via l'Interface Web

1. Dans votre repository, cliquez sur **Add file** → **Upload files**
2. Glissez-déposez tous vos dossiers et fichiers
3. Écrivez un message de commit : "Initial commit"
4. Cliquez sur **Commit changes**

#### Option B : Via Git (Ligne de Commande)

```bash
# Dans le dossier local de votre projet
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/maxstack.git
git push -u origin main
```

### Étape 5 : Vérifier les URLs

Vérifiez que ces URLs fonctionnent dans votre navigateur :

- `https://raw.githubusercontent.com/VOTRE_USERNAME/maxstack/main/version.txt`
- `https://raw.githubusercontent.com/VOTRE_USERNAME/maxstack/main/main.ms`
- `https://raw.githubusercontent.com/VOTRE_USERNAME/maxstack/main/scripts/list.txt`

Si vous voyez le contenu, c'est bon ! ✅

### Étape 6 : Modifier update.ms

Dans le fichier `update/update.ms`, modifiez la ligne 107 :

**Avant :**
```maxscript
local baseURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/"
```

**Après :**
```maxscript
local baseURL = "https://raw.githubusercontent.com/VOTRE_USERNAME/maxstack/main/"
```

Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub.

## 🚀 Publication d'une Nouvelle Version

### Workflow de Mise à Jour

1. **Modifiez vos scripts** localement
2. **Ajoutez de nouveaux scripts** si nécessaire
3. **Mettez à jour les fichiers list.txt** :
   - `scripts/list.txt` : ajoutez les nouveaux scripts
   - `icons/list.txt` : ajoutez les nouvelles icônes

4. **Incrémentez la version** dans `version.txt` :
   ```
   1.0.0  →  1.0.1  (correction de bug)
   1.0.0  →  1.1.0  (nouvelle fonctionnalité)
   1.0.0  →  2.0.0  (changement majeur)
   ```

5. **Committez et pushez** :
   ```bash
   git add .
   git commit -m "Version 1.0.1 - Ajout de nouveaux outils"
   git push
   ```

6. **Créez un Release GitHub** (optionnel mais recommandé) :
   - Allez dans **Releases** → **Create a new release**
   - Tag version : `v1.0.1`
   - Title : `Version 1.0.1`
   - Description : Liste des changements
   - Attachez un ZIP avec l'installateur

### Exemple de Commit Message

```
Version 1.0.1

Nouveautés:
- Ajout de _MyTools_Modeling_QuickBevel.ms
- Ajout de _MyTools_Animation_KeyframeHelper.ms

Corrections:
- Fix du bug de collision dans Mirror Tool
- Amélioration de la performance du menu builder

Mise à jour:
- scripts/list.txt
- icons/list.txt
- version.txt
```

## 🔄 Processus de Mise à Jour pour Utilisateurs

### Comment vos utilisateurs recevront les mises à jour

1. **Au démarrage de 3ds Max** :
   - MaxStack vérifie automatiquement GitHub
   - Compare `version.txt` local vs distant
   - Si nouvelle version → popup de mise à jour

2. **L'utilisateur accepte** :
   - Téléchargement automatique des nouveaux fichiers
   - Mise à jour de `version.txt` local
   - Message de confirmation

3. **Redémarrage de 3ds Max** :
   - Les nouveaux scripts apparaissent dans le menu
   - Les nouvelles icônes sont chargées

## 🛡️ Sécurité et Bonnes Pratiques

### ✅ À FAIRE

- Toujours tester localement avant de pusher
- Incrémenter la version à chaque changement
- Mettre à jour les fichiers `list.txt`
- Écrire des messages de commit clairs
- Créer des releases pour les versions importantes

### ❌ À NE PAS FAIRE

- Ne jamais pousser de scripts non testés
- Ne jamais supprimer de fichiers sans incrémenter la version majeure
- Ne jamais rendre le repository privé (les mises à jour ne fonctionneront plus)
- Ne pas oublier de mettre à jour `scripts/list.txt` et `icons/list.txt`

## 📦 Distribution Initiale

### Créer un Package d'Installation

1. Créez un dossier `MaxStack_v1.0.0/`
2. Copiez tous les fichiers et dossiers
3. Créez un ZIP : `MaxStack_v1.0.0.zip`
4. Uploadez sur GitHub Releases

### Instructions pour les Utilisateurs

```
Installation de MaxStack
========================

1. Téléchargez MaxStack_v1.0.0.zip
2. Extrayez le contenu
3. Ouvrez 3ds Max
4. MaxScript → Run Script
5. Sélectionnez "installer.ms"
6. Redémarrez 3ds Max
7. Le menu MaxStack apparaît !

Les mises à jour seront automatiques.
```

## 🔍 Dépannage GitHub

### Les mises à jour ne fonctionnent pas

**Problème :** "Impossible de vérifier les mises à jour"

**Solutions :**
1. Vérifiez que le repository est **public**
2. Vérifiez l'URL dans `update.ms`
3. Testez l'URL dans un navigateur
4. Vérifiez la connexion internet

### Les nouveaux fichiers ne se téléchargent pas

**Problème :** Les scripts ne sont pas mis à jour

**Solutions :**
1. Vérifiez `scripts/list.txt` sur GitHub
2. Vérifiez que les noms de fichiers sont exacts
3. Vérifiez qu'il n'y a pas de ligne vide à la fin
4. Vérifiez que `version.txt` a été incrémenté

### Erreur 404 lors du téléchargement

**Problème :** "Fichier non trouvé"

**Solutions :**
1. Vérifiez que le fichier existe sur GitHub
2. Vérifiez le nom exact (sensible à la casse)
3. Vérifiez le chemin complet dans l'URL
4. Attendez quelques minutes (propagation GitHub)

## 📊 Statistiques et Suivi

### Voir qui utilise votre outil

GitHub fournit des statistiques :
- **Insights** → **Traffic** : Nombre de clones et visiteurs
- **Insights** → **Commits** : Historique des modifications
- **Releases** : Nombre de téléchargements par version

### Recevoir des Feedbacks

Activez les **Issues** sur GitHub :
1. **Settings** → **Features**
2. Cochez **Issues**
3. Les utilisateurs peuvent rapporter des bugs ou demander des fonctionnalités

## 🎓 Ressources

- [GitHub Docs](https://docs.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Semantic Versioning](https://semver.org/)

## ✅ Checklist de Publication

Avant chaque publication :

- [ ] Tous les scripts testés localement
- [ ] `version.txt` incrémenté
- [ ] `scripts/list.txt` à jour
- [ ] `icons/list.txt` à jour
- [ ] README.md à jour si nécessaire
- [ ] Commit avec message descriptif
- [ ] Push vers GitHub
- [ ] Vérification des URLs raw.githubusercontent.com
- [ ] Test de mise à jour depuis 3ds Max
- [ ] Création d'un Release (pour versions majeures)

---

**Note :** Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub dans tous les exemples.
