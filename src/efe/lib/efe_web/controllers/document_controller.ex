defmodule EFEWeb.DocumentController do
  use EFEWeb, :controller

  alias EFE.Documents
  alias EFE.Documents.Document

  def index(conn, _params) do
    documents = Documents.list_documents()
    render(conn, :index, documents: documents)
  end

  def new(conn, _params) do
    changeset = Documents.change_document(%Document{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"document" => document_params}) do
    case Documents.create_document(document_params) do
      {:ok, document} ->
        conn
        |> put_flash(:info, "Document created successfully.")
        |> redirect(to: ~p"/documents/#{document}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    render(conn, :show, document: document)
  end

  def editor(conn, %{"path" => path}) do
    with {:ok, path} <- Documents.safe_relative_path(path) do
      conn
      |> put_root_layout(false)
      |> put_layout(false)
      |> assign(:document_server_url, Application.fetch_env!(:efe, :document_server_url))
      |> assign(:base_url, EFEWeb.Endpoint.url())
      |> assign(:doc_path, path)
      |> render(:editor)
    else
      :error -> send_resp(conn, :forbidden, "")
    end
  end

  def edit(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    changeset = Documents.change_document(document)
    render(conn, :edit, document: document, changeset: changeset)
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Documents.get_document!(id)

    case Documents.update_document(document, document_params) do
      {:ok, document} ->
        conn
        |> put_flash(:info, "Document updated successfully.")
        |> redirect(to: ~p"/documents/#{document}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, document: document, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    {:ok, _document} = Documents.delete_document(document)

    conn
    |> put_flash(:info, "Document deleted successfully.")
    |> redirect(to: ~p"/documents")
  end
end
