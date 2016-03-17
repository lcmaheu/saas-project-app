class ArtifactsController < ApplicationController
  before_action :set_artifact, only: [:show, :edit, :update, :destroy]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  # GET /artifacts
  # GET /artifacts.json
  def index
    flash[:danger] = "Access denied"
    redirect_to root_path
  end

  # GET /artifacts/1
  # GET /artifacts/1.json
  def show
  end

  # GET /artifacts/new
  def new
    @artifact = Artifact.new
    @artifact.project_id = params[:project_id]
  end

  # GET /artifacts/1/edit
  def edit
  end

  # POST /artifacts
  # POST /artifacts.json
  def create
    @artifact = Artifact.new(artifact_params)
    @artifact.owner = current_user.id

    respond_to do |format|
      if @artifact.save
        format.html { redirect_to tenant_project_url(
                                      tenant_id: Tenant.current_tenant_id,
                                      id: @artifact.project_id) }
        format.json { render :show, status: :created, location: @artifact }
      else
        format.html { render :new }
        format.json { render json: @artifact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artifacts/1
  # PATCH/PUT /artifacts/1.json
  def update
    respond_to do |format|
      if @artifact.update(artifact_params)
        format.html { redirect_to tenant_project_url(tenant_id: Tenant.current_tenant_id, id: @artifact.project_id),
                                  notice: 'File was updated.' }
        format.json { render :show, status: :ok, location: @artifact }
      else
        format.html { render :edit }
        format.json { render json: @artifact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /artifacts/1
  # DELETE /artifacts/1.json
  def destroy
    @artifact.destroy
    respond_to do |format|
      format.html { redirect_to tenant_project_url(tenant_id: Tenant.current_tenant_id, id: @artifact.project_id),
                                notice: 'File was destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_artifact
    @artifact = Artifact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def artifact_params
    params.require(:artifact).permit(:name, :project_id, :upload)
  end

  def require_same_user
    unless (current_user.id == @artifact.project.owner) || (current_user.id == @artifact.owner) || current_user.is_admin?
      flash[:danger] = "You can edit or delete only your own artifacts"
      redirect_to root_path
    end
  end

end
