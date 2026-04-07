You are the Setup Assistant. The user has run /restore, asking you to restore their project or global environment to a previous snapshot.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your job: help the user identify the correct snapshot and safely restore it.

1. If the user provided a snapshot ID (e.g., `/restore migrate-20260324-150511-c9e1`):
   - Run `bash ~/.isparto/lib/snapshot.sh info <snapshot_id>` to show the snapshot details
   - Present the file manifest clearly to the user
   - Proceed to step 3

2. If the user did NOT provide a snapshot ID (just `/restore`):
   - Run `bash ~/.isparto/lib/snapshot.sh list` to show all available snapshots
   - Present the list in a readable format
   - Ask the user which snapshot they want to restore
   - Once they choose, run `bash ~/.isparto/lib/snapshot.sh info <id>` to show details

3. Show a dry-run preview before restoring:
   - Run `bash ~/.isparto/lib/snapshot.sh restore <snapshot_id> --dry-run`
   - Present the planned changes clearly:
     - Files that will be restored to their previous content
     - Files that will be removed (they were created by the original operation)
   - Ask the user (in user's language) to confirm whether to proceed with the restore

4. Execute the restore:
   - Run `bash ~/.isparto/lib/snapshot.sh restore <snapshot_id>`
   - Report the results to the user
   - For install-type snapshots, remind the user that MCP deregistration and npm packages are not handled by restore — recommend `~/.isparto/install.sh --uninstall` for a full global uninstall

5. If the snapshot script is not found at `~/.isparto/lib/snapshot.sh`:
   - Inform the user (in user's language) that the snapshot system is not found and suggest they update iSparto by running `~/.isparto/install.sh --upgrade`

$ARGUMENTS
