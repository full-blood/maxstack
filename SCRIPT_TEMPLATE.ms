-- =====================================================
-- _MyTools_CATEGORY_ActionName.ms
-- DESCRIPTION DE VOTRE SCRIPT
-- =====================================================
-- Version: 1.0.0
-- Auteur: Votre Nom
-- Date: 2024-XX-XX
-- =====================================================

macroScript MyTools_ActionName 
    category:"MyTools" 
    tooltip:"DESCRIPTION COURTE"
    buttonText:"ACTION"
(
    -- ========================================
    -- VARIABLES GLOBALES (si nécessaire)
    -- ========================================
    
    -- ========================================
    -- FONCTIONS UTILITAIRES
    -- ========================================
    
    fn doSomething obj =
    (
        -- Votre code ici
        return true
    )
    
    -- ========================================
    -- INTERFACE UTILISATEUR (optionnelle)
    -- ========================================
    
    rollout MyToolRollout "Mon Outil"
    (
        -- CONTRÔLES
        group "Options"
        (
            spinner spn_value "Valeur:" range:[0,100,50] type:#integer
            checkbox chk_option "Option Active" checked:true
        )
        
        button btn_execute "Exécuter" width:140 height:30
        
        -- ÉVÉNEMENTS
        on btn_execute pressed do
        (
            if selection.count == 0 then
            (
                messageBox "Veuillez sélectionner au moins un objet" title:"Mon Outil"
                return false
            )
            
            undo "Mon Outil" on
            (
                -- Votre logique principale
                for obj in selection do
                (
                    doSomething obj
                )
                
                format "✓ Opération réussie sur % objet(s)\n" selection.count
            )
            
            messageBox "Opération terminée!" title:"Mon Outil"
        )
    )
    
    -- ========================================
    -- POINT D'ENTRÉE
    -- ========================================
    
    -- Afficher l'interface
    createDialog MyToolRollout 200 150
    
    -- OU exécution directe (sans interface)
    -- if selection.count > 0 then
    -- (
    --     for obj in selection do
    --         doSomething obj
    -- )
)


-- =====================================================
-- NOTES DE DÉVELOPPEMENT
-- =====================================================
-- 
-- Convention de nommage:
-- - Fichier: _Prefix_Category_ActionName.ms
-- - Macro: Prefix_ActionName
-- - Rollout: ActionNameRollout
-- 
-- Catégories courantes:
-- - Modeling
-- - Transform
-- - Material
-- - Animation
-- - Rendering
-- - Utilities
-- 
-- Icône associée:
-- - Nom: _MyTools_CATEGORY_ActionName.png
-- - Taille: 16x16 ou 24x24 pixels
-- - Format: PNG avec transparence
-- 
-- =====================================================
