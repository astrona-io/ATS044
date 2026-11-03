# Get Your Machine Ready

You need a Markdown reader or the Astrona reading interface. A browser can display the repository pages. The course uses Mermaid diagrams, a text format that the reading interface turns into drawings. If your reader does not display a diagram, the surrounding prose still explains its mechanism.

The hands-on steps run in a playground, which is a small Kubernetes cluster that the `astrona` command-line tool starts for you with kind (Kubernetes in Docker). Install a container engine such as Docker, `kubectl` and the `astrona` tool. You do not need a cloud account or an existing cluster. Start a playground with `astrona run`, check what is running with `astrona list` and remove it with `astrona destroy`.

Every module has a playground for practice and a graded lab that you submit with `astrona submit`. Each section ends with a capstone lab and a knowledge check. The labs are new and are not yet tested on a live cluster, so report a lab that fails to start or grade.

Use a notebook to record unfamiliar terms and your reasoning for each practice answer. When a page is missing, check that you are viewing the content branch or published revision that contains this draft. If a diagram or reading fails to load, record the page title and the visible error when reporting the issue.
