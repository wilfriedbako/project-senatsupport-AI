async function submitTicket() {

    const message = document.getElementById("message").value;

    const resultBox = document.getElementById("result");

    resultBox.innerHTML = "Submitting ticket...";

    try {

        const response = await fetch(
            "https://l4d4ais87h.execute-api.us-east-1.amazonaws.com/ticket",
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    message: message
                })
            }
        );

        const data = await response.json();

        resultBox.innerHTML = `
            <h2>Ticket Created</h2>

            <p><strong>Ticket ID:</strong> ${data.ticket}</p>

            <p><strong>Category:</strong> ${data.category}</p>

            <p><strong>Urgency:</strong> ${data.urgency}</p>

            <p><strong>Assigned Engineer:</strong> ${data.assigned_to}</p>

            <p><strong>Status:</strong> ${data.status}</p>

            <p><strong>Summary:</strong> ${data.summary}</p>
        `;

    } catch (error) {

        resultBox.innerHTML = `
            <p>Error submitting ticket</p>
        `;

        console.error(error);
    }
}