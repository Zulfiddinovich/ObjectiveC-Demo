### ObjectiveC-Demo

    ProjectDirectory
        - AppDelegate
            - Supporting Files
                - Prefix.pch
        - Common
            - Categorys
            - Supers
        - Modules
        - Resource
            - Storyboards
        - Scenes
            - Commons
            - Intro
            - Root

    ProjectTestsDirectory
    Thirdpartys
        - Frameworks
        - Librarys
        - Opensources

# To release debug app
- 'Product' -> 'Clean Build folder'
- 'Product' -> 'Archive' (or for existing archives: 'Window' -> 'Organizer')
- 'Distribute app' -> 'Custom' -> 'Debugging' -> Choose thinning
- Select distribution certificate and import team profile (mobile provision)
- 'Export after checking 'ipa' content
- Choose directory then new directory will be created with ipa files.