class GithubActionsGenerator
  def initialize
    print "container_registry_url: "
    container_registry_url = gets.chomp

    print "container_registry: "
    container_registry = gets.chomp

    print "repository_name: "
    repository_name = gets.chomp
    @github_actions = <<~HEREDOC
                      name: build and push docker image
                      on:
                        workflow_dispatch:
                        pull_request:
                          branches: [ main ]
                          types: [ closed ]
                          paths-ignore:
                            - .github/**
                            - .gitignore
                            - README.md
                      env:
                        CONTAINER_REGISTRY_URL: #{container_registry_url}
                        CONTAINER_REGISTRY: #{container_registry}
                        REPO_NAME: #{repository_name}
                        RELEASE_FOLDER: helm
                      concurrency: prod_deploy
                      jobs:
                        build:
                          if: ${{ github.event.pull_request.merged == true || github.event_name == 'workflow_dispatch' }}
                          runs-on: ubuntu-latest
                          steps:
                            - name: checkout repository
                              uses: actions/checkout@v2
                              with:
                                ref: main
                    
                            - name: Set outputs
                              id: vars
                              run: echo "::set-output name=sha_short::$(git rev-parse --short HEAD)"
                    
                            - name: Login to Container Registry
                              id: login-to-gh-cr
                              run: docker login -u ${{ env.REPO_NAME }} -p ${{ env.REPO_NAME }} ${{ env.CONTAINER_REGISTRY_URL }}
                    
                            - name: build image
                              id: build-image
                              run: docker build -t ${{ env.CONTAINER_REGISTRY_URL }}/${{ env.CONTAINER_REGISTRY }}/${{ env.REPO_NAME }}:latest -t ${{ env.CONTAINER_REGISTRY_URL }}/${{ env.CONTAINER_REGISTRY }}/${{ env.REPO_NAME }}:ex-${{ steps.vars.outputs.sha_short }} .
                    
                            - name: push image
                              id: push-image
                              run: docker push --all-tags ${{ env.CONTAINER_REGISTRY_URL }}/${{ env.CONTAINER_REGISTRY }}/${{ env.REPO_NAME }}
                    
                            - name: update image
                              id: update-image
                              run: |
                                sed -i "s/tag:.*/tag: ex-${{ steps.vars.outputs.sha_short }}/g" ${{ env.RELEASE_FOLDER }}/values.yaml
                    
                            - name: commit-changes
                              run: |
                                git config user.name github-actions
                                git config user.email github-actions@github.com
                                git add .
                                git commit -m "[Release] image ${{ steps.vars.outputs.sha_short }}"
                                git push
                      HEREDOC
  end
    
  def generate
    FileUtils.mkdir_p(".github/workflows") unless File.exist?(".github/workflows")
    File.write(".github/workflows/build.yml", @github_actions)
  end
end