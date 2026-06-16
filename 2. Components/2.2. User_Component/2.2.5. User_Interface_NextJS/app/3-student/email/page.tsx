"use client";

import { useState, useEffect } from "react";
import { safeFetch } from "@/lib/safeFetch";
import {
  Mail,
  Trash2,
  Reply,
  Send,
  Paperclip,
  Plus,
} from "lucide-react";

/* ------------------ TYPES ------------------ */

type Email = {
  emailCode: number;
  subject: string;
  content: string;
  arrivalTime: string;
  importance: string;
  senderName: string;
  receiverName: string;
  attachment?: any;
};

/* ------------------ MAIN PAGE ------------------ */

export default function EmailPage() {
  const [inbox, setInbox] = useState<Email[]>([]);
  const [sent, setSent] = useState<Email[]>([]);
  const [selectedEmail, setSelectedEmail] = useState<Email | null>(null);
  const [composeOpen, setComposeOpen] = useState(false);

  async function loadInbox() {
    const res = await safeFetch("/email/inbox");
    if (res.ok) setInbox(await res.json());
  }

  async function loadSent() {
    const res = await safeFetch("/email/sent");
    if (res.ok) setSent(await res.json());
  }

  useEffect(() => {
    loadInbox();
    loadSent();
  }, []);

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <Mail className="w-8 h-8" /> Email Center
        </h1>

        <button
          onClick={() => setComposeOpen(true)}
          className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-md"
        >
          <Plus size={18} /> Compose
        </button>
      </div>

      {/* ------------------ Inbox ------------------ */}
      <section className="mb-10">
        <h2 className="text-xl font-semibold mb-3">Inbox</h2>

        <div className="space-y-3">
          {inbox.map((email) => (
            <div
              key={email.emailCode}
              className="p-4 border rounded-lg hover:bg-gray-50 cursor-pointer flex justify-between"
              onClick={() => setSelectedEmail(email)}
            >
              <div>
                <p className="font-semibold">{email.subject}</p>
                <p className="text-sm text-gray-600">
                  From: {email.senderName}
                </p>
                <p className="text-xs text-gray-400">
                  {new Date(email.arrivalTime).toLocaleString()}
                </p>
              </div>

              <button
                className="text-red-500 hover:text-red-700"
                onClick={(e) => {
                  e.stopPropagation();
                  // TODO: delete endpoint
                }}
              >
                <Trash2 size={20} />
              </button>
            </div>
          ))}
        </div>
      </section>

      {/* ------------------ Sent ------------------ */}
      <section>
        <h2 className="text-xl font-semibold mb-3">Sent</h2>

        <div className="space-y-3">
          {sent.map((email) => (
            <div
              key={email.emailCode}
              className="p-4 border rounded-lg hover:bg-gray-50 cursor-pointer flex justify-between"
              onClick={() => setSelectedEmail(email)}
            >
              <div>
                <p className="font-semibold">{email.subject}</p>
                <p className="text-sm text-gray-600">
                  To: {email.receiverName}
                </p>
                <p className="text-xs text-gray-400">
                  {new Date(email.arrivalTime).toLocaleString()}
                </p>
              </div>

              <button
                className="text-red-500 hover:text-red-700"
                onClick={(e) => {
                  e.stopPropagation();
                  // TODO: delete endpoint
                }}
              >
                <Trash2 size={20} />
              </button>
            </div>
          ))}
        </div>
      </section>

      {/* ------------------ Email View Modal ------------------ */}
      {selectedEmail && (
        <EmailModal
          email={selectedEmail}
          onClose={() => setSelectedEmail(null)}
        />
      )}

      {/* ------------------ Compose Modal ------------------ */}
      {composeOpen && (
        <ComposeEmailModal onClose={() => setComposeOpen(false)} />
      )}
    </div>
  );
}

/* ------------------ EMAIL VIEW MODAL ------------------ */

function EmailModal({
  email,
  onClose,
}: {
  email: Email;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[600px] rounded-lg p-6 shadow-xl">
        <h2 className="text-2xl font-bold mb-2">{email.subject}</h2>

        <p className="text-sm text-gray-600 mb-4">
          From: {email.senderName} •{" "}
          {new Date(email.arrivalTime).toLocaleString()}
        </p>

        <p className="mb-4 whitespace-pre-line">{email.content}</p>

        {email.attachment && (
          <div className="flex items-center gap-2 p-2 bg-gray-100 rounded-md mb-4">
            <Paperclip size={18} />
            <span>Attachment</span>
          </div>
        )}

        <div className="flex justify-end gap-2">
          <button className="px-3 py-1 bg-gray-200 rounded" onClick={onClose}>
            Close
          </button>
          <button className="px-3 py-1 bg-blue-600 text-white rounded flex items-center gap-1">
            <Reply size={16} /> Reply
          </button>
        </div>
      </div>
    </div>
  );
}

/* ------------------ COMPOSE EMAIL MODAL ------------------ */

function ComposeEmailModal({ onClose }: { onClose: () => void }) {
  const [to, setTo] = useState("");
  const [subject, setSubject] = useState("");
  const [content, setContent] = useState("");

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[600px] rounded-lg p-6 shadow-xl">
        <h2 className="text-2xl font-bold mb-4">Compose Email</h2>

        <input
          className="w-full border p-2 rounded mb-3"
          placeholder="To (user ID)"
          value={to}
          onChange={(e) => setTo(e.target.value)}
        />

        <input
          className="w-full border p-2 rounded mb-3"
          placeholder="Subject"
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
        />

        <textarea
          className="w-full border p-2 rounded mb-3 h-32"
          placeholder="Message..."
          value={content}
          onChange={(e) => setContent(e.target.value)}
        />

        <div className="flex justify-end gap-2">
          <button className="px-3 py-1 bg-gray-200 rounded" onClick={onClose}>
            Cancel
          </button>
          <button className="px-3 py-1 bg-green-600 text-white rounded flex items-center gap-1">
            <Send size={16} /> Send
          </button>
        </div>
      </div>
    </div>
  );
}
