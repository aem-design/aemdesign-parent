AEM.Design Contributing
=======================

# How to add new Repos

Adding a new repo, if needed for everyone

- Create repo in GitLab:
```https://github.com/aem-design/ ```

- Put the repo to ```.gitignore``` of parent project

- Git init, add, commit and push the repo over to BitBucket

- Add repo entry to ```REPOLIST``` in ```scripts/functions-repoman.sh```

- Other developers can clone the newly added repos by running

```bash
./devops clone
```

- Add install script into your repo if it needs dependencies, update both ```devops``` for windows and ```parent/pom.xml``` profile ```dependencies``` for general dependency install cycle

# Making Changes

- Create Issue in GitLab for changes

- Create new branch named after the issue and pull

- Checkout branch and make changes, commit and push

- Create Merge Request and assign to relevant assignee to sign off on changes

# DevOps Scripts

## DevOps AutoComplete

DevOps script has Auto Complete to activate pres tab after typing ```./devops {TAB}```

## DevOps Script Updates

Please use [Shellcheck](https://github.com/koalaman/shellcheck) (lint) when updating script and fix all recommendations, try not to add ignores.


# Content Cleaning

Please clean your content when checking it into codebase, use Regex search and replace in the IDE to replace all mathing lines with empty stirg.

You will need to do this couple of time. At very least please remove Account and Unique ID info.


# Replace all identifier attributes

<table>
    <thead>
        <tr>
            <th>Pattern</th>
            <th>Replace With</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <pre>^.+(cq|jcr)\:(createdBy|lastReplicatedBy|lastModifiedBy|lastReplicated|lastReplicationAction|uuid)\=\".+\"\n</pre>
            </td>
            <td>
                <pre></pre>
            </td>
        </tr>
        <tr>
            <td>
                <pre>^.+(cq|jcr)\:(createdBy|lastReplicatedBy|lastModifiedBy|lastReplicated|lastReplicationAction|uuid|)\=\".+\"\></pre>
            </td>
            <td>
                <pre>&gt;</pre>
            </td>
        </tr>
    </tbody>
</table>

# Remove all system generated attributes

<table>
    <thead>
        <tr>
            <th>Pattern</th>
            <th>Replace With</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <pre>^.+(cq|jcr)\:(created|lastReplicated|lastModified|lastReplicationAction|uuid)\=\".+\"\n</pre>
            </td>
            <td>
                <pre></pre>
            </td>
        </tr>
        <tr>
            <td>
                <pre>^.+(cq|jcr)\:(created|lastReplicated|lastModified|lastReplicationAction|uuid)\=\".+\"\></pre>
            </td>
            <td>
                <pre>&gt;</pre>
            </td>
        </tr>
    </tbody>
</table>

# Remove all generated component attributes

| Pattern                                   | Replace With      |
|-------------------------------------------|-------------------|
| ```^.+(componentId)\=\".+\"\n```          |                   |
| ```^.+(componentId)\=\".+\"\>```          | ```>```           |
| ```^.+(componentId)\=\".+\"\/>```         | ```/>```          |
