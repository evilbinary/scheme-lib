(library (surfage s98 os-environment-variables)
  (export
    (rename (lookup-process-environment get-environment-variable)
            (process-environment->alist get-environment-variables)))
  (import
    (only (core) lookup-process-environment process-environment->alist)))
