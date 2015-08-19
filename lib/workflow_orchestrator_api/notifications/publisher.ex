require Logger

defmodule OpenAperture.WorkflowOrchestratorApi.Notifications.Publisher do
  use GenServer

  @moduledoc """
  This module contains the logic to publish messages to the Notifications system module
  """

  alias OpenAperture.ManagerApi

  alias OpenAperture.Messaging.AMQP.QueueBuilder
  alias OpenAperture.Messaging.ConnectionOptionsResolver

  alias OpenAperture.ManagerApi

  @connection_options nil
  use OpenAperture.Messaging

  @doc """
  Specific start_link implementation (required by the supervisor)

  ## Options

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t}
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Method to publish a hipchat notification

  ## Options

  The `exchange_id` option defines the exchange in which Notification messages should be sent

  The `broker_id` option defines the broker to which the Notification messages should be sent

  The `is_success` option is a boolean that determines success

  The `prefix` option is the message prefix String

  The `message` option is the message content

  The `room_names` option is (optionally) HipChat room names to publish to

  ## Return Values

  :ok | {:error, reason}
  """
  @spec hipchat_notification(String.t, String.t, term, String.t, String.t, List) :: :ok | {:error, String.t}
  def hipchat_notification(exchange_id, broker_id, is_success, prefix, message, room_names \\ nil) do
    payload = %{
      is_success: is_success,
      prefix:     prefix,
      message:    message,
      room_names: room_names
    }

    GenServer.cast(__MODULE__, {:hipchat, exchange_id, broker_id, payload})
  end

  @doc """
  Method to publish a email notification

  ## Options

  The `exchange_id` option defines the exchange in which Notification messages should be sent

  The `broker_id` option defines the broker to which the Notification messages should be sent

  The `subject` option defines the email subject

  The `message` option defines the body of the email

  The `recipients` option defines an array of email addresses of recipients

  ## Return Values

  :ok | {:error, reason}
  """
  @spec email_notification(String.t, String.t, String.t, String.t, List) :: :ok | {:error, String.t}
  def email_notification(exchange_id, broker_id, subject, message, recipients) do
    payload = %{
      prefix:        subject,
      message:       message,
      notifications: %{email_addresses: recipients}
    }

    GenServer.cast(__MODULE__, {:email, exchange_id, broker_id, payload})
  end

  @doc """
  Cast handler to publish Notifications

  ## Options

  The `notification_type` option defines an atom representing what type of notification should be sent (i.e. :hipchat, :email)

  The `exchange_id` option defines the exchange in which Notification messages should be sent

  The `broker_id` option defines the broker to which the Notification messages should be sent

  The `payload` option defines the Hipchat Notification payload that should be sent

  The `state` option represents the server's current state

  ## Return Values

  {:noreply, state}
  """
  @spec handle_cast({term, String.t, String.t, map}, map) :: {:noreply, map}
  def handle_cast({notification_type, exchange_id, broker_id, payload}, state) do
    notification_type_string = to_string(notification_type)
    queue   = QueueBuilder.build(ManagerApi.get_api, "notifications_#{notification_type_string}", exchange_id)
    options = ConnectionOptionsResolver.get_for_broker(ManagerApi.get_api, broker_id)
    case publish(options, queue, payload) do
      :ok -> Logger.debug("[WorkflowOrchestratorApi][NotificationsPublisher] Successfully published #{notification_type_string} notification")
      {:error, reason} -> Logger.error("[WorkflowOrchestratorApi][NotificationsPublisher] Failed to publish #{notification_type_string} notification:  #{inspect reason}")
    end

    {:noreply, state}
  end
end
