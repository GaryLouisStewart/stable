# A helmchart that combines both the offical hashicorp consul and vault services into one umbrella chart to install both of them in parallel to a kubernetes cluster.


1) Gather the required dependencies for this chart please use the following command.

    ```
    $ helm dependency update

    # should return the following output below #

    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "hashicorp" chart repository
    ...Successfully got an update from the "stable" chart repository
    Update Complete. ⎈Happy Helming!⎈
    Saving 2 charts
    Downloading consul from repo https://helm.releases.hashicorp.com
    Downloading vault from repo https://helm.releases.hashicorp.com
    Deleting outdated charts
    ```

2) Install the chart to a kubernetes cluster of your choice.
    ```
    # helm install <release-name> <chart-path> -f dynamic-duo/values.yaml
    $ helm install vk ./dynamic-duo/ -f dynamic-duo/values.yaml
    ```

3) List and check the release that you now have.
   ```
   $ helm ls
   # should return output that is similar to below.
   NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
   vk              default         1               2020-08-15 13:48:23.501659 +0100 BST    deployed        dynamic-duo-0.1.0 
   ```

4) your chart should now be installed, you can expose the pods in order to reach the consul-ui and vault-ui.
these pods use the official hashicorp consul + vault helm charts, so anything you want to configure on them can be utilised. I have 