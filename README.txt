HOW TO GET THE .deb (no computer tools needed)
1. Make a free account at github.com, create a new repository.
2. Click "Add file" > "Upload files", drag in EVERYTHING from this folder (keep the folders).
   The hidden .github folder must be included. If the browser skips it, create the file
   .github/workflows/build.yml via "Add file" > "Create new file" and paste its contents.
3. Open the "Actions" tab. The build runs automatically (or press "Run workflow").
4. When it finishes (~3-5 min), open the run and download the "MotionSpoofer-deb" artifact.
   Unzip it, install the .deb with Sileo/Filza, then respring.
