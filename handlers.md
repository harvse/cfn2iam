Information Provided by AWS Q on the CFN docs page:

- Add (Create):

  - Primary handler: Create
  - Secondary handler: Read (to verify the creation)

- Modify (Update):

  - Primary handler: Update
  - Secondary handlers:
    - Read (to get the current state before update)
    - Read (to verify the update after completion)

- Remove (Delete):

  - Primary handler: Delete
  - Secondary handler: Read (to verify the deletion)

- Import:

  - Primary handler: Create (with special import flag)
  - Secondary handlers:
    - Read (to verify the import)
    - List (to identify existing resources for import)

- Dynamic:
  - This is a special case where the action is determined at runtime
  - Handlers invoked depend on the actual action determined:
  - Could be Create, Read, Update, or Delete
